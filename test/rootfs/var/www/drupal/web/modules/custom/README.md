# Custom Modules

We need two separate modules as islandora requires all the taxonomy terms to be
present to function correctly, having just the direct dependencies is not
enough.

`sample_core` is installed first, followed by `sample_content`.

We include the `taxonomy_terms` that are normally ingested via the `migrate-api`
using this module as we need a consistent `uuid` for each to properly link the
default content to them as `id` changes on every re-install.
