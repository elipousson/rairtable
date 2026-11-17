#' Match a variable to a vector of field_types
#'
#' @noRd
field_type_match <- function(
  type,
  values = rairtable::field_types[["type"]],
  error_arg = caller_arg(type),
  error_call = caller_env()
) {
  arg_match(
    type,
    values = values,
    error_arg = error_arg,
    error_call = error_call
  )
}

#' Match a field name to a vector of names from a table model
#'
#' @noRd
field_name_match <- function(
  nm,
  values = NULL,
  model = NULL,
  multiple = TRUE,
  error_arg = caller_arg(nm),
  error_call = caller_env()
) {
  if (is_null(values) && !is_null(model)) {
    model_fields <- model[["fields"]]
    if (is.data.frame(model)) {
      model_fields <- model_fields[[1]]
    }
    if (is.data.frame(model_fields)) {
      values <- c(model_fields[["name"]], model_fields[["id"]])
    } else {
      values <- c(
        names_at(model_fields),
        unlist(lapply(model_fields, function(x) x[["id"]]))
      )
    }
  }

  arg_match(
    nm,
    values = values,
    multiple = multiple,
    error_arg = error_arg,
    error_call = error_call
  )
}
