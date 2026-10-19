#' Create an `airtable_fields_schema` object
#'
#' Create an `airtable_fields_schema` object from a list of lists to use for
#' data validation.
#'
#' @param field_schema A list of lists. Each child list should have a `name`,
#'   `type`, and `id` as well as an optional `options`
#' @return An `airtable_fields_schema` object
#' @export
airtable_fields_schema <- function(field_schema) {
  new_airtable_fields_schema(field_schema)
}

#' @noRd
new_airtable_fields_schema <- function(fields, call = caller_env()) {
  check_list(fields, call = call)
  fields <- vctrs::new_vctr(fields, class = "airtable_fields_schema")
  check_airtable_fields_schema(fields, call = call)
  fields
}

#' Is x have an airtable_fields_schema class?
#'
#' @noRd
is_airtable_fields_schema <- function(x) {
  inherits(x, "airtable_fields_schema")
}

#' Error if fields does not meet the requirements for an airtable_fields_schema
#' object
#'
#' Note: this function maybe could use [check_airtable_field()]
#'
#' @noRd
check_airtable_fields_schema <- function(fields, call = caller_env()) {
  require_names <- c("name", "id", "type")
  allow_names <- c(require_names, "description", "options")
  fields_names <- lapply(fields, names)

  has_required <- vapply(
    fields_names,
    function(nm) all(require_names %in% nm),
    TRUE
  )

  if (!all(has_required)) {
    cli_abort(
      "Every item in {.arg fields} must be a list with the names
      {.val {require_names}}.",
      call = call
    )
  }

  extra_names <- setdiff(unlist(fields_names), allow_names)

  if (length(extra_names) > 0) {
    cli_abort(
      "{.arg fields} names must be
      {.val {cli::cli_vec(allow_names, style = list('vec-last' = ', or '))}},
      not {.val {extra_names}}.",
      call = call
    )
  }

  invisible(NULL)
}
