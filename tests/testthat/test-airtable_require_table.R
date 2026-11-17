test_that("airtable supports base urls if require_table is FALSE", {
  withr::local_envvar(AIRTABLE_PAT = "test_pat")
  url <- "https://airtable.com/appxyz123"

  expect_error(airtable(url, description = "Test base"))

  atbl <- airtable(url, require_table = FALSE, description = "Test base")

  expect_s3_class(atbl, "airtable")
  expect_identical(atbl[["base"]], "appxyz123")
  expect_null(atbl[["table"]])
})

test_that("airtable still requires a table by default", {
  expect_error(airtable(base = "appxyz123", description = "Test base"))
  expect_error(airtable(table = "tbl123"))
})

test_that("airtable(api_version) is deprecated", {
  withr::local_envvar(AIRTABLE_PAT = "test_pat")

  lifecycle::expect_deprecated(
    airtable(
      "tblabc123",
      "appxyz123",
      description = "Test base",
      api_version = 0
    )
  )
})
