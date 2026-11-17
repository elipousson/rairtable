#' Create a field or column in an Airtable table
#'
#' Create a field or column in the table of an Airtable base. Find more
#' information on the create field API method and field types and options in the
#' Airtable Web API documentation:
#' <https://airtable.com/developers/web/api/create-field> Both name and type are
#' required unless config is provided.
#'
#' @param name Name for the field or column to create.
#' @param type Field type, defaults to 'singleLineText'. See
#'   `field_types` for list of supported field types.
#' @param description Optional. Description for the field or column to create or
#'   description to add to updated field. Description must be no longer than
#'   20,000 characters.
#' @param options Named list of field options. Required for some field types.
#'   See the Airtable Web API documentation on field types and cell values for
#'   more information: <https://airtable.com/developers/web/api/field-model>
#'   Default: `NULL`.
#' @param config A named list that can be used to set the name, type,
#'   description, or options of a field to create, e.g. a field config created
#'   by [make_field_config()] or [get_field_config()]. Values in config take
#'   precedence over the name, type, description, and options parameters.
#' @inheritParams req_airtable
#' @return A list with the created field name, field ID, description (if
#'   provided), and options.
#' @export
#' @importFrom httr2 req_perform
create_field <- function(
  airtable = NULL,
  name = NULL,
  type = "singleLineText",
  description = NULL,
  options = NULL,
  config = NULL,
  token = NULL,
  ...
) {
  if (!is_null(config)) {
    check_list(config)
    name <- config[["name"]] %||% name
    type <- config[["type"]] %||% type
    description <- config[["description"]] %||% description
    options <- config[["options"]] %||% options
  }

  check_name(name)
  type <- field_type_match(type)
  check_field_description(description, allow_null = TRUE)
  check_list(options, allow_null = TRUE)

  data <- list(
    description = description,
    name = name,
    options = options,
    type = type
  )

  resp <- request_airtable_meta(
    airtable = airtable,
    meta = "create_field",
    data = data,
    token = token,
    ...
  )

  invisible(httr2::resp_body_json(resp))
}


#' @rdname create_field
#' @name update_field
#' @param field Field ID of the field to update. Can be a field URL.
#' @export
#' @importFrom httr2 resp_body_json
update_field <- function(
  airtable = NULL,
  field = NULL,
  name = NULL,
  description = NULL,
  token = NULL,
  ...
) {
  check_name(name, allow_null = TRUE)
  check_field_description(description)

  resp <- request_airtable_meta(
    airtable = airtable,
    meta = "update_field",
    column = field,
    data = list(
      name = name,
      description = description
    ),
    method = "PATCH",
    token = token,
    ...
  )

  invisible(httr2::resp_body_json(resp))
}


#' Check field description
#'
#' @noRd
check_field_description <- function(
  description = NULL,
  allow_null = TRUE,
  call = caller_env()
) {
  if (allow_null && is_null(description)) {
    return(invisible(NULL))
  }

  check_string(description, allow_empty = FALSE, call = call)

  if (nchar(description) > 20000) {
    cli_abort(
      "{.arg description} must be a string no longer than 20,000 characters.",
      call = call
    )
  }
}
