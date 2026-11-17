#' Create a new airtable object
#'
#' Creates an S3 airtable object, which serves as a pointer for rairtable
#' functions.
#'
#' @param table Required. Airtable table ID or name. Table ID values start with
#'   "tbl". If table is an Airtable URL matching the pattern
#'   "https://airtable.com/\{baseID\}/\{tableIdOrName\}/\{viewId\}" the URL
#'   is parsed to supply the values for base and table. If table is a named list with the
#'   names "id", "name", and "description", the value for id is used as the
#'   value of table and name and description are passed to the respective
#'   parameters.
#' @param base Airtable base ID. Base ID values start with "app". Optional if
#'   table is a URL containing a base ID or required otherwise.
#' @param view Optional Airtable view ID. View ID values starts with "viw".
#' @param fields An optional `airtable_fields_schema` object. Automatically
#'   populated in tables created by `airtable_base()`.
#' @inheritParams request_airtable
#' @param api_version Deprecated. Airtable API version. Version is now part of
#'   default api_url.
#' @param name,description Airtable table name and table description. Optional.
#'   Description is only set if supplied (or available from the table schema)
#'   and is otherwise left blank; it is never replaced by the base or table
#'   name.
#' @param base_name Airtable base name. Optional and only used for printing.
#'   Stored separately from `description`.
#' @param lookup If `TRUE`, check the table against the base schema and fill in
#'   details from Airtable. This requires a token with the "schema.bases:read"
#'   scope and makes two API requests ([list_bases()] and [get_table_models()]).
#'   The function errors if no table matching `table` (an ID or a name) is
#'   found in the base. If found, a table name is resolved to its table ID and
#'   the table `name`, `description`, and `fields` are set from the schema
#'   unless they are supplied. `description` stays blank if the table does not
#'   have a description. The base name and your permission level for the base
#'   are also set. If `FALSE` (default), no request is made and the object is
#'   not validated against Airtable. To get every table in a base, use
#'   [airtable_base()].
#' @param ... Additional parameters passed to [check_airtable_obj()]. Primarily
#'   intended for internal use.
#'
#' @return An `airtable` class list of table and fields stored as values of the
#'   list and the base, view, and request_url stored as attributes.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' table <- airtable("Table 1", "appXXXXXXXXXXXXX")
#' }
airtable <- function(
  table,
  base = NULL,
  view = NULL,
  fields = list(),
  name = NULL,
  description = NULL,
  api_url = NULL,
  api_version = deprecated(),
  token = NULL,
  base_name = NULL,
  lookup = FALSE,
  ...
) {
  atbl <- new_airtable_obj(
    base = base,
    table = table,
    view = view,
    fields = fields,
    name = name,
    description = description,
    base_name = base_name,
    lookup = lookup,
    api_url = api_url,
    token = token
  )

  # A table name (unlike a table ID) does not start with "tbl" so only require
  # a table ID in the request URL if table is a table ID
  check_airtable_obj(
    atbl,
    require_table = is_table_id(atbl[["table"]]),
    ...
  )

  atbl
}

#' Coerce an airtable object or Airtable URL to an airtable object
#'
#' `as_airtable()` is the single place where functions that act on a table
#' resolve their `airtable` argument. `airtable` objects are returned unchanged.
#' An Airtable URL (a base, table, or view URL or an API URL) is parsed and
#' converted to an `airtable` object without making an API request. `NULL` is
#' returned unchanged so callers can keep supporting other ways of identifying a
#' table.
#'
#' Anything else, including a bare table name, is an error because a table name
#' can't be resolved without a base ID. A URL must include a table ID because an
#' `airtable` object always identifies a table.
#'
#' @param x An `airtable` object, Airtable URL, or `NULL`.
#' @param arg Argument name used in error messages.
#' @inheritParams rlang::args_error_context
#' @noRd
as_airtable <- function(x, arg = caller_arg(x), call = caller_env()) {
  if (is_null(x) || is_airtable_obj(x)) {
    return(x)
  }

  if (is_string(x) && (is_airtable_url(x) || is_airtable_api_url(x))) {
    ids <- parse_airtable_url(x, require_table = TRUE, call = call)

    return(
      airtable(
        table = ids[["table"]],
        base = ids[["base"]],
        view = ids[["view"]],
        call = call
      )
    )
  }

  cli_abort(
    c(
      "{.arg {arg}} must be an {.cls airtable} object or an Airtable URL,
      not {.obj_type_friendly {x}}.",
      "i" = "Use {.fn airtable} with a base ID and table name to create an
      object from names."
    ),
    call = call
  )
}

#' Look up a table model in the base schema and error if it is not found
#'
#' @param table Table ID or name.
#' @noRd
lookup_table_model <- function(base, table, token = NULL, call = caller_env()) {
  models <- get_table_models(
    base = base,
    tables = table,
    token = token,
    simplifyVector = FALSE,
    call = call
  )

  if (is_empty(models)) {
    cli_abort(
      "Can't find a table matching {.val {table}} in base {.val {base}}.",
      call = call
    )
  }

  models[[1]]
}

#' Create a new airtable object
#'
#' @noRd
#' @importFrom vctrs new_vctr
new_airtable_obj <- function(
  base,
  table,
  view = NULL,
  fields = NULL,
  api_url = NULL,
  description = NULL,
  name = NULL,
  base_name = NULL,
  lookup = FALSE,
  token = NULL,
  call = caller_env()
) {
  if (is_list(table)) {
    description <- description %||% table[["description"]]
    name <- name %||% table[["name"]]
    table <- table[["id"]]
  }

  check_string(table, call = call)

  if (is_airtable_url(table)) {
    ids <- parse_airtable_url(
      table,
      require_table = TRUE,
      require_view = FALSE,
      call = call
    )

    base <- ids[["base"]]
    table <- ids[["table"]]
    view <- ids[["view"]]
  }

  check_string(base, call = call)
  check_character(view, allow_null = TRUE, call = call)

  permissions <- list()

  if (is_true(lookup)) {
    base_info <- list_bases(bases = base, token = token)
    base_name <- base_name %||% base_info[["name"]]
    permissions <- base_info[["permissionLevel"]] %||% list()

    model <- lookup_table_model(base, table, token = token, call = call)

    # Resolve a table name to the table ID
    table <- model[["id"]]
    name <- name %||% model[["name"]]
    description <- description %||% model[["description"]]

    if (is_empty(fields)) {
      fields <- as.list(
        vapply(model[["fields"]], function(x) x[["name"]], character(1))
      )
    }
  }

  req <- request_airtable_api_url(
    base = base,
    table = table,
    view = view,
    api_url = api_url,
    call = call
  )

  base_url <- getOption("rairtable.base_url", "https://airtable.com")
  base_url <- glue("{base_url}/{base}")

  table_url <- NULL
  if (is_table_id(table)) {
    table_url <- as.character(glue("{base_url}/{table}"))
  } else {
    name <- name %||% table
  }

  request_url <- req[["url"]]

  vctrs::new_vctr(
    .data = vctrs::list_drop_empty(
      list(
        "base" = base,
        "base_name" = base_name,
        "description" = description,
        "table" = table,
        "name" = name,
        "view" = view %||% list(),
        "fields" = fields %||% list(),
        "permissions" = permissions,
        "base_url" = base_url,
        "table_url" = table_url,
        "request_url" = request_url
      )
    ),
    class = "airtable"
  )
}

#' @export
#' @importFrom vctrs vec_data
format.airtable <- function(x, ...) {
  formatC(vctrs::vec_data(x))
}

#' @export
vec_ptype_abbr.airtable <- function(x, ...) {
  "atbl"
}

#' @export
vec_ptype_full.airtable <- function(x, ...) {
  "airtable"
}

#' @export
#' @importFrom cli cli_text cli_rule cli_bullets
print.airtable <- function(x, ...) {
  cli::cli_text("{.cls {class(x)}}")

  rule_msg <- ""

  if (!is_empty(x$base_name)) {
    rule_msg <- "{.val {x$base_name}}"
  }

  cli::cli_rule(rule_msg)

  text <- c("*" = "Base: {.field {x$base}}")

  if (!is_empty(x$table)) {
    tbl_msg <- "Table: {.val {x$name}} - {.field {x$table}}"

    if (is_empty(x$name)) {
      tbl_msg <- "Table: {.field {x$table}}"
    }

    text <- c(text, "*" = tbl_msg)

    if (!is_empty(x$description)) {
      text <- c(text, " " = "Description: {x$description}")
    }
  }

  if (!is_empty(x$view)) {
    text <- c(text, "*" = "View: {.field {x$view}}")
  }

  if (!is_empty(x$fields)) {
    fields <- cli::cli_vec(
      x$fields,
      list("vec-trunc" = getOption("rairtable.fields-trunc", 6))
    )

    text <- c(
      text,
      "*" = "{length(x$fields)} field{?s} including {.field {fields}}."
    )
  }

  cli::cli_bullets(text)
  cli::cli_rule("{.url {x$table_url %||% x$base_url}}")
  invisible(x)
}
