web_url <- "https://airtable.com/appABCDEFGHIJKLMN/tblABCDEFGHIJKLMN/viwABCDEFGHIJKLMN"
api_url <- "https://api.airtable.com/v0/appABCDEFGHIJKLMN/tblABCDEFGHIJKLMN"

test_that("as_airtable passes through NULL and airtable objects", {
  expect_null(as_airtable(NULL))

  atbl <- airtable(
    table = "tblABCDEFGHIJKLMN",
    base = "appABCDEFGHIJKLMN"
  )

  expect_identical(as_airtable(atbl), atbl)
})

test_that("as_airtable converts Airtable and API URLs without a request", {
  httptest2::without_internet({
    from_web <- as_airtable(web_url)
    from_api <- as_airtable(api_url)
  })

  expect_s3_class(from_web, "airtable")
  expect_identical(from_web[["base"]], "appABCDEFGHIJKLMN")
  expect_identical(from_web[["table"]], "tblABCDEFGHIJKLMN")
  expect_identical(from_web[["view"]], "viwABCDEFGHIJKLMN")

  expect_s3_class(from_api, "airtable")
  expect_identical(from_api[["table"]], "tblABCDEFGHIJKLMN")
})

test_that("as_airtable rejects table names, lookalike hosts, and other types", {
  expect_error(as_airtable("Table 1"), "must be an")
  expect_error(
    as_airtable("https://airtable.com.example.org/appABCDEFGHIJKLMN/tblABCDEFGHIJKLMN"),
    "must be an"
  )
  expect_error(as_airtable(1L), "must be an")
  expect_error(
    as_airtable("https://airtable.com/appABCDEFGHIJKLMN"),
    "table ID"
  )
})

test_that("request_airtable builds the same request from an object or a URL", {
  atbl <- airtable(
    table = "tblABCDEFGHIJKLMN",
    base = "appABCDEFGHIJKLMN",
    view = "viwABCDEFGHIJKLMN"
  )

  expect_identical(
    request_airtable(airtable = web_url)[["url"]],
    request_airtable(airtable = atbl)[["url"]]
  )
})
