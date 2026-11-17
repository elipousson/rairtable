# Test base and table used to record the mock fixtures (see setup.R). These IDs
# already appear in the fixture file paths so they are not treated as secrets.
rairtable_test_base <- "appu39z5mdXIsevUX"
rairtable_test_table <- "tbl0MzEDRrELyD57V"
rairtable_test_view <- "viwtQYeduYs7pvuwF"

get_rairtable_test_url <- function(url = NULL) {
  url %||%
    paste0(
      "https://airtable.com/",
      rairtable_test_base,
      "/",
      rairtable_test_table,
      "/",
      rairtable_test_view
    )
}

# Get a test `airtable` object with get_rairtable_test_obj
get_rairtable_test_obj <- function(url = NULL, table = NULL, ...) {
  airtable(
    table = table %||% get_rairtable_test_url(url),
    ...
  )
}
