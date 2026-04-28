<?php

namespace Drush\Commands;

use Drush\Drush;
use Symfony\Component\HttpFoundation\Request;
use Drupal\Core\Site\Settings;
use Symfony\Component\Filesystem\Filesystem;

/**
 * A Drush command file.
 *
 * In addition to this file, you need a drush.services.yml
 * in root of your module, and a composer.json file that provides the name
 * of the services file to use.
 *
 * See these files for an example of injecting Drupal services:
 *   - http://cgit.drupalcode.org/devel/tree/src/Commands/DevelCommands.php
 *   - http://cgit.drupalcode.org/devel/tree/drush.services.yml
 */
class UpdateSettingsCommands extends DrushCommands {

  /**
   * Creates in settings.php from default.settings.php if missing.
   *
   * @command islandora:settings:create-settings-if-missing
   * @bootstrap site
   * @usage drush islandora:settings:create-settings-if-missing
   *   Creates settings.php in sites directory if missing.
   */
  public function createSettingsIfMissing() {
    $settings_file = $this->getSettingFilePath();
    $fs = new Filesystem();
    if (!$fs->exists($settings_file)) {
      // After drush site-install has been run it is possible for the default
      // directory to be non-writable by anyone.
      $site_directory = dirname($settings_file);
      $prev = fileperms($site_directory);
      $fs->chmod($site_directory, 0775);
      $fs->copy(DRUPAL_ROOT . '/sites/default/default.settings.php', $settings_file);
      $fs->chmod($site_directory, $prev);
    }
  }

  /**
   * Set `config_sync_directory` in settings.php.
   *
   * @param string $path
   *   The path to use for the `config_sync_directory` setting.
   *
   * @command islandora:settings:set-config-sync-directory
   * @bootstrap site
   * @usage drush islandora:settings:set-config-sync-directory ../config/sync
   *   Sets `config_sync_directory` in settings.php.
   */
  public function setConfigSyncDirectory($path) {
    $settings['settings']['config_sync_directory'] = (object) [
      'value' => $path,
      'required' => TRUE,
    ];
    $this->writeSettings($settings);
  }

  /**
   * Set `hash_salt` in settings.php.
   *
   * @param string $salt
   *   The value of the salt.
   *
   * @command islandora:settings:set-hash-salt
   * @bootstrap site
   * @usage drush islandora:settings:set-hash-salt IpWSRBrkTDKAL_ykij_WJJrnqcDv
   *   Sets `hash_salt` in settings.php. Use something like
   *   Crypt::randomBytesBase64(55).
   */
  public function setHashSalt($salt) {
    $settings['settings']['hash_salt'] = (object) [
      'value' => $salt,
      'required' => TRUE,
    ];
    $this->writeSettings($settings);
  }

  /**
   * Set `flysystem` in settings.php.
   *
   * @param string $url
   *   The root URL to Fedora.
   *
   * @command islandora:settings:set-flystem-fedora-url
   * @bootstrap site
   * @usage drush islandora:settings:set-flystem-fedora-url http://fcrepo.isle-dc.localhost/fcrepo/rest/
   *   Sets `flysystem` in settings.php.
   */
  public function setFlystemFedoraUrl($url) {
    $settings['settings']['flysystem']['fedora']['driver'] = (object) [
      'value' => 'fedora',
      'required' => TRUE,
    ];
    $settings['settings']['flysystem']['fedora']['config']['root'] = (object) [
      'value' => $url,
      'required' => TRUE,
    ];
    $this->writeSettings($settings);
  }

  /**
   * Set `database` settings in settings.php.
   *
   * @param string $database
   *   The name of the database.
   * @param string $username
   *   The user name to connect with.
   * @param string $password
   *   The password of the user.
   * @param string $host
   *   The database host.
   * @param string|int $port
   *   The database port.
   * @param string $driver
   *   Database driver defaults to `mysql`.
   * @param string $prefix
   *   Table prefix.
   *
   * @command islandora:settings:set-database-settings
   * @bootstrap site
   *   Sets `database` in settings.php.
   */
  public function setDatabaseSettings(
    $database,
    $username,
    $password,
    $host,
    $port,
    $driver = 'mysql',
    $prefix = '',
  ) {
    $default_database['database'] = (object) [
      'value' => $database,
      'required' => TRUE,
    ];
    $default_database['username'] = (object) [
      'value' => $username,
      'required' => TRUE,
    ];
    $default_database['password'] = (object) [
      'value' => $password,
      'required' => TRUE,
    ];
    $default_database['host'] = (object) [
      'value' => $host,
      'required' => TRUE,
    ];
    $default_database['port'] = (object) [
      'value' => $port,
      'required' => TRUE,
    ];
    $default_database['prefix'] = (object) [
      'value' => $prefix,
      'required' => TRUE,
    ];
    $default_database['driver'] = (object) [
      'value' => $driver,
      'required' => TRUE,
    ];
    $default_database['namespace'] = (object) [
      'value' => 'Drupal\\Core\\Database\\Driver\\' . $driver,
      'required' => TRUE,
    ];
    $settings['databases']['default']['default'] = $default_database;
    $this->writeSettings($settings);
  }

  /**
   * Set `trusted_host_patterns` in settings.php.
   *
   * @param string $patterns
   *   List of comma-separated patterns.
   *
   * @command islandora:settings:set-trusted-host-patterns
   * @bootstrap site
   * @usage drush islandora:settings:set-trusted-host-patterns "^localhost$,^192\\.168\\.00\\.52$,^127\\.0\\.0\\.1$"
   *   Sets `trusted_host_patterns` in settings.php.
   *   Be aware that shell escaping can have an affect on the arguments.
   */
  public function setTrustedHostPatterns($patterns) {
    $settings['settings']['trusted_host_patterns'] = (object) [
      'value' => explode(',', $patterns),
      'required' => TRUE,
    ];
    $this->writeSettings($settings);
  }

  /**
   * Set `reverse_proxy` in settings.php.
   *
   * @param string $reverse_proxy_ips
   *   List of comma-separated IP addresses for the reverse proxy.
   *
   * @command islandora:settings:set-reverse-proxy
   * @bootstrap site
   * @usage drush islandora:settings:set-reverse-proxy
   *   Sets `reverse_proxy` in settings.php.
   *   Be aware that shell escaping can have an affect on the arguments.
   */
  public function setReverseProxySettings($reverse_proxy_ips) {
    $settings['settings']['reverse_proxy'] = (object) [
      'value' => TRUE,
      'required' => TRUE,
    ];
    $settings['settings']['reverse_proxy_addresses'] = (object) [
      'value' => explode(',', $reverse_proxy_ips),
      'required' => TRUE,
    ];
    $settings['settings']['reverse_proxy_trusted_headers'] = (object) [
      'value' => Request::HEADER_X_FORWARDED_FOR |
      Request::HEADER_X_FORWARDED_PROTO |
      Request::HEADER_X_FORWARDED_PORT,
      'required' => TRUE,
    ];
    $this->writeSettings($settings);
  }

  /**
   * Determine which settings file to update.
   */
  private function getSettingFilePath() {
    return DRUPAL_ROOT . "/" . Drush::bootstrap()->confPath() . "/settings.php";
  }

  /**
   * Determine which settings file to update.
   */
  private function writeSettings($settings) {
    require_once DRUPAL_ROOT . '/core/includes/install.inc';
    $settings_file = $this->getSettingFilePath();
    $fs = new Filesystem();
    $fs->chmod($settings_file, 0755);
    new Settings([]);
    drupal_rewrite_settings($settings, $settings_file);
    $fs->chmod($settings_file, 0400);
  }

}
