#' Create and perform a request for the Airtable Metadata API
#'
#' Create and perform a request to get or update metadata for bases, tables, or
#' fields using the Airtable metadata API. This is a low-level function that
#' the higher-level functions such as [create_table()] and [update_field()] are
#' built on. Use it to call metadata API endpoints that do not have a
#' corresponding function in this package by supplying a `template`.
#'
#' Note that the metadata API does *not* support the legacy Airtable API key so
#' a personal access token is required. Save a personal access token with
#' [set_airtable_pat()]. This function does not currently provide a `meta`
#' option for the API for views or permissions which are both limited to
#' Enterprise user accounts.
#'
#' @inheritParams request_airtable
#' @param url An Airtable URL used to find the base, table, or column ID if
#'   `base`, `table`, or `column` are not supplied. Not used to build the
#'   request.
#' @param column Field ID, Defaults to `NULL`. Only required when `meta =
#'   "update_field"`. Column can be a field URL. The metadata API refers to
#'   this value as the `columnId`.
#' @param ... Additional parameters passed to [req_airtable()] (including
#'   `method` for a custom template).
#' @param meta Type of metadata API call to use for bases, tables, or fields.
#'   Options include "schema_base", "create_base", "list_base", "update_table",
#'   "create_table", "update_field", or "create_field". Optional if template is
#'   provided.
#' @param template URL template passed to [req_airtable()] if meta is `NULL`.
#'   Any of `{base}`, `{table}`, and `{column}` in the template are filled in
#'   from the `base`, `table`, and `column` parameters (or from `airtable` or
#'   `url`). The template is relative to the API URL, e.g. `"meta/whoami"`.
#' @returns An HTTP response as an S3 list with class httr2_response.
#'
#' @examples
#' \dontrun{
#' # List all bases with a built-in request
#' request_airtable_meta(meta = "list_base")
#'
#' # Call an endpoint that does not have a function in this package
#' resp <- request_airtable_meta(
#'   template = "meta/bases/{base}/webhooks",
#'   base = "appXXXXXXXXXXXXX"
#' )
#' httr2::resp_body_json(resp)
#' }
#' @export
#' @importFrom vctrs list_drop_empty
#' @importFrom httr2 req_perform
request_airtable_meta <- function(
  url = NULL,
  base = NULL,
  table = NULL,
  column = NULL,
  airtable = NULL,
  ...,
  meta = NULL,
  template = NULL,
  data = NULL,
  token = NULL,
  call = caller_env()
) {
  base_required <- FALSE
  table_required <- FALSE
  column_required <- FALSE

  if (is_null(template)) {
    meta <- arg_match(
      meta,
      c(
        "create_base",
        "list_base",
        "schema_base",
        "create_table",
        "update_table",
        "create_field",
        "update_field"
      ),
      error_call = call
    )

    base_required <- !(meta %in% c("create_base", "list_base"))
    table_required <- meta %in%
      c("update_table", "update_field", "create_field")
    column_required <- (meta == "update_field")
  } else {
    # For a custom template, resolve any ID that the template uses
    base_required <- grepl("{base}", template, fixed = TRUE)
    table_required <- grepl("{table}", template, fixed = TRUE)
    column_required <- grepl("{column}", template, fixed = TRUE)
  }

  template <- template %||%
    paste0(
      "meta/bases",
      switch(
        meta,
        "create_base" = "",
        "list_base" = "",
        "schema_base" = "/{base}/tables",
        "create_table" = "/{base}/tables",
        "update_table" = "/{base}/tables/{table}",
        "create_field" = "/{base}/tables/{table}/fields",
        "update_field" = "/{base}/tables/{table}/fields/{column}"
      )
    )

  if (base_required) {
    base <- get_base_id(
      base = base,
      airtable = airtable,
      url = url,
      call = call
    )

    check_string(base, allow_empty = FALSE, call = call)
  }

  if (table_required) {
    table <- get_table_id(
      table = table,
      airtable = airtable,
      url = url,
      call = call
    )

    check_string(table, allow_empty = FALSE, call = call)
  }

  if (column_required) {
    column <- get_field_id(column, url = url, call = call)

    check_string(column, allow_empty = FALSE, call = call)
  }

  if (is_list(data)) {
    data <- vctrs::list_drop_empty(data)
  }

  req <- req_airtable(
    base = base,
    table = table,
    column = column,
    template = template,
    ...,
    data = data,
    token = token,
    call = call,
    require_base = FALSE,
    require_table = FALSE,
    allow_key = FALSE
  )

  httr2::req_perform(req, error_call = call)
}
