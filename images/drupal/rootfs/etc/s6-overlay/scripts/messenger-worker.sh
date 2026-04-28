#!/usr/bin/with-contenv bash
set -euo pipefail

TRANSPORT="${1:?missing transport}"
ENABLED_VALUE_INPUT="${2:-}"
readonly TRANSPORT ENABLED_VALUE_INPUT

function log_info {
    echo "s6-rc: info: messenger-worker(${TRANSPORT}): ${*}" >&2
}

function is_truthy {
    case "${1,,}" in
    1|true|yes|on)
        return 0
        ;;
    *)
        return 1
        ;;
    esac
}

function resolve_worker_uri {
    if [[ -n "${DRUSH_OPTIONS_URI:-}" ]]; then
        printf '%s\n' "${DRUSH_OPTIONS_URI}"
        return
    fi

    if [[ -n "${DRUPAL_DEFAULT_SITE_URL:-}" ]]; then
        printf '%s\n' "${DRUPAL_DEFAULT_SITE_URL}"
        return
    fi

    printf '\n'
}

function build_drush_args {
    local -n _args_ref=$1
    _args_ref=("sm:consume" "${TRANSPORT}" "--time-limit=${DRUPAL_SM_WORKERS_TIME_LIMIT:-3600}")

    if [[ -n "${DRUPAL_SM_WORKERS_FETCH_SIZE:-}" ]]; then
        _args_ref+=("--fetch-size=${DRUPAL_SM_WORKERS_FETCH_SIZE}")
    fi

    if [[ -n "${DRUPAL_SM_WORKERS_NO_RESET:-}" ]] && is_truthy "${DRUPAL_SM_WORKERS_NO_RESET}"; then
        _args_ref+=("--no-reset")
    fi

    if [[ -n "${WORKER_URI:-}" ]]; then
        _args_ref+=("--uri=${WORKER_URI}")
    fi
}

function build_sm_args {
    local -n _args_ref=$1
    _args_ref=("messenger:consume" "${TRANSPORT}" "--time-limit=${DRUPAL_SM_WORKERS_TIME_LIMIT:-3600}")

    if [[ -n "${DRUPAL_SM_WORKERS_NO_RESET:-}" ]] && is_truthy "${DRUPAL_SM_WORKERS_NO_RESET}"; then
        _args_ref+=("--no-reset")
    fi
}

function can_use_drush_consume {
    local drush_args=("--root=/var/www/drupal/web")
    if [[ -n "${WORKER_URI:-}" ]]; then
        drush_args+=("--uri=${WORKER_URI}")
    fi
    drush "${drush_args[@]}" list --format=list 2>/dev/null | grep -qx 'sm:consume'
}

function can_use_sm_binary {
    [[ -x "/var/www/drupal/vendor/bin/sm" ]]
}

cd /var/www/drupal

while true; do
    RETRY_DELAY="${DRUPAL_SM_WORKERS_RETRY_DELAY:-30}"
    MODE="${DRUPAL_SM_WORKERS_MODE:-external}"
    ENABLED_VALUE="${ENABLED_VALUE_INPUT:-true}"
    WORKER_URI="$(resolve_worker_uri)"
    export DRUSH_OPTIONS_URI="${WORKER_URI}"

    if [[ "${MODE}" != "container" ]]; then
        log_info "local workers disabled because DRUPAL_SM_WORKERS_MODE=${MODE}; sleeping ${RETRY_DELAY}s"
        sleep "${RETRY_DELAY}"
        continue
    fi

    if ! is_truthy "${ENABLED_VALUE}"; then
        log_info "local worker disabled by enabled flag value ${ENABLED_VALUE}; sleeping ${RETRY_DELAY}s"
        sleep "${RETRY_DELAY}"
        continue
    fi

    DRUSH_STATUS_ARGS=("--root=/var/www/drupal/web")
    if [[ -n "${WORKER_URI}" ]]; then
        DRUSH_STATUS_ARGS+=("--uri=${WORKER_URI}")
    fi

    if ! drush "${DRUSH_STATUS_ARGS[@]}" status --fields=bootstrap >/dev/null 2>&1; then
        log_info "waiting for Drupal bootstrap; sleeping ${RETRY_DELAY}s"
        sleep "${RETRY_DELAY}"
        continue
    fi

    if can_use_sm_binary; then
        SM_ARGS=()
        build_sm_args SM_ARGS
        log_info "starting vendor/bin/sm ${SM_ARGS[*]}"
        if vendor/bin/sm "${SM_ARGS[@]}"; then
            log_info "worker exited cleanly; restarting"
        else
            EXIT_CODE=$?
            log_info "worker exited with code ${EXIT_CODE}; retrying after ${RETRY_DELAY}s"
            sleep "${RETRY_DELAY}"
        fi
        continue
    fi

    if can_use_drush_consume; then
        DRUSH_ARGS=()
        build_drush_args DRUSH_ARGS
        log_info "starting drush ${DRUSH_ARGS[*]}${WORKER_URI:+ with uri ${WORKER_URI}}"
        if drush --root=/var/www/drupal/web "${DRUSH_ARGS[@]}"; then
            log_info "worker exited cleanly; restarting"
        else
            EXIT_CODE=$?
            log_info "worker exited with code ${EXIT_CODE}; retrying after ${RETRY_DELAY}s"
            sleep "${RETRY_DELAY}"
        fi
        continue
    fi

    log_info "no compatible consumer command found; retrying after ${RETRY_DELAY}s"
    sleep "${RETRY_DELAY}"
done
