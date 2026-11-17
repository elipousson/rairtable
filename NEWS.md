# rairtable (development)

This is a major update of the original version of the rairtable package. The package has been refactored to use the `{httr2}` package, a large number of new functions have been added, along with new features for existing functions.

General changes:

* Add cli, glue, httr2, lifecycle, rlang, tibble, tidyselect, and vctrs to Imports.
* Remove httr, jsonlite, tibble, dplyr, crayon, parallel, and progress from Imports.
* Add httptest2, knitr, rmarkdown, and testthat to Suggests.

New functions for working with several components of the Airtable Web API:

* Bases: `create_base()`, `list_bases()`, and `get_base_schema()`
* Records: `list_records()` and `get_record()` 
* Tables and table configurations: `create_table()`, `get_table_model()`, `get_table_models()`, `make_table_config()`, and `copy_table_config()`
* Fields and field configurations: `create_field()`, `update_field()`, `get_field_config()`, and `make_field_config()`
* Comments: `list_comments()`, `create_comment()`, `delete_comment()`

Updated functions:

* `airtable()` now supports parsing Airtable URLs to derive Airtable base, table, and view ID values. Support for parsing URLs is now available for most functions in the package.
* `airtable()` no longer makes an API request when an object is created. `table` is required (as in the previous release) unless `require_table = FALSE` is used with a base URL. Use the new `lookup = TRUE` parameter to check the table against the base schema (an error if it is not found), resolve a table name to its ID, and set the base name, permissions, table name, description, and fields; or supply `base_name`. Use `airtable_base()` to get every table in a base. `description` is now only ever the description defined in Airtable and is left blank otherwise (it is never replaced by a base or table name).
* `delete_records()` and `update_records()` now work with a vector of record URLs. `delete_records()` now builds the multi-record query with `httr2::req_url_query()`.
* `is_airtable_url()` and the API URL check now match the URL prefix literally and reject lookalike hosts such as "https://airtable.com.example.org".
* `get_table_id()` now works when passed an `airtable` object.
* `request_airtable()`, `req_airtable()`, and the new exported `request_airtable_meta()` are documented as low-level helpers for calling parts of the Airtable API that do not have a corresponding function. A table URL can now be supplied to the `airtable` parameter of any function that takes an airtable object. The separate `url` parameter of `request_airtable()` and `req_airtable()` is removed. `request_airtable_meta()` now works with a custom `template`.
* Parameter names now follow the Airtable API vocabulary: `update_field()` takes a `field` (ID or URL) and `create_field()` takes a `config` list. `delete_records()` uses `return_data` (like `insert_records()` and `update_records()`).
* `read_airtable()` (along with `list_records()`) now supports the full range of parameters for the record query API.

Breaking changes:

* The `parallel` argument of `insert_records()` and `update_records()` has been removed. `batch_size` is deprecated in `insert_records()`, `create_records()`, and `delete_records()`; set the `rairtable.batch_size` option instead.
* `read_airtable(max_rows)` and `airtable(api_version)` are deprecated and now warn when used. Use `list_records(max_records)` to limit the number of records.
* The arguments of several functions have been reordered or added. Positional arguments after the first two may need to be named: `airtable()` (`fields`, `name`, and `description` now come before `api_url`), `update_records()` (`airtable_id_col` now comes before `columns`), and `delete_records()` (`records` now comes before `safely`).
* `airtable_id_col` and `columns` in `update_records()` are now strings and tidyselect expressions that are evaluated in the same way as other tidyselect functions, not unevaluated expressions.
* The confirmation prompt used by `update_records()` and `delete_records()` is now a text prompt where pressing Enter confirms. It was a menu that required choosing "Yes". It still errors in non-interactive sessions unless `safely = FALSE` or the `rairtable.safely` option is set.
* Minimum versions are now R 4.1.0, httr2 1.0.0, tidyselect 1.2.0, and vctrs 0.6.0.

Other changes:

* Add @elipousson as co-author.

# rairtable 0.1.1

* Basic Airtable CRUD functionality
