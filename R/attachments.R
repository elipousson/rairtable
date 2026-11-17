#' Download files from an Airtable attachment field
#'
#' @description
#' Learn more about the attachment field type:
#' <https://airtable.com/developers/web/api/field-model#multipleattachment>
#'
#' Learn more about attachments in Airtable:
#' <https://support.airtable.com/docs/airtable-attachment-url-behavior>
#'
#' @param data An Airtable data frame with an attachment list column selected
#'   with the field parameter *or* an attachment list column.
#' @param field Attachment field or column name as string or tidyselect function.
#' @param path Path to download file.
#' @inheritParams rlang::args_error_context
#' @keywords internal
download_attachment_field <- function(
  data,
  field = NULL,
  path = NULL,
  ...,
  call = caller_env()
) {
  if (!is.null(field)) {
    check_data_frame(data, call = call)
    data <- select_cols(
      tidyselect::any_of(field),
      .data = data,
      error_call = call
    )
    ncol_data <- ncol(data)

    if (ncol_data > 1) {
      cli::cli_abort(
        "{.arg field} must select only one attachment column, not {ncol_data}.",
        call = call
      )
    }

    data <- data[[1]]
  }

  url_list <- attachment_to_url_list(data)

  # File names come from the Airtable base so only use the last path component
  # to keep files inside path
  filenames <- make.unique(basename(names(url_list)))
  path <- path %||% getwd()

  walk(
    seq_along(url_list),
    function(i) {
      utils::download.file(
        url = url_list[[i]],
        destfile = file.path(path, filenames[[i]]),
        ...
      )
    }
  )
}

#' Convert attachment column to named vector of URLs named with file names
#'
#' @param data Attachment data frame list column.
#' @noRd
attachment_to_url_list <- function(.l, filename = NULL) {
  url <- map(.l, function(x) {
    x[["url"]]
  })

  filename <- filename %||%
    map(.l, function(x) {
      x[["filename"]]
    })

  set_names(unlist(url), unlist(filename))
}
