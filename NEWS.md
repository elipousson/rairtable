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
* `read_airtable()` (along with `list_records()`) now supports the full range of parameters for the record query API.

Other changes:

* Add @elipousson as co-author.

# rairtable 0.1.1

* Basic Airtable CRUD functionality
