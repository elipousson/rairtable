test_that("request_airtable works", {
  atbl <- get_rairtable_test_obj()

  expect_s3_class(
    request_airtable(airtable = atbl),
    "httr2_request"
  )

  expect_s3_class(
    request_airtable(airtable = get_rairtable_test_url()),
    "httr2_request"
  )

  expect_s3_class(
    request_airtable(base = "app", table = "tbl"),
    "httr2_request"
  )
})

test_that("request_airtable errors", {
  expect_error(
    request_airtable(),
    "`airtable` or `base` and `table` must be supplied."
  )

  expect_error(
    request_airtable(airtable = 1),
    "`airtable` must be an <airtable> object or an Airtable URL, not a number."
  )

  expect_error(
    request_airtable(airtable = "airtable.com"),
    "must be an <airtable> object or an Airtable URL"
  )

  expect_error(
    request_airtable(airtable = "https://airtable.com"),
    "`url` is not valid."
  )
})

test_that("req_airtable works", {
  atbl <- get_rairtable_test_obj()
  req <- request_airtable(airtable = atbl)
  req <- req_airtable(req)

  expect_s3_class(
    req,
    "httr2_request"
  )

  expect_identical(
    req$options$useragent,
    getOption(
      "rairtable.useragent",
      default = "rairtable (https://github.com/matthewjrogers/rairtable)"
    )
  )

  expect_identical(
    req$url,
    paste0(
      c(
        getOption("rairtable.api_url", "https://api.airtable.com/v0"),
        atbl$base,
        atbl$table
      ),
      collapse = "/"
    )
  )
})

test_that("request_airtable can build a base-level request", {
  req <- request_airtable(base = "appABCDEFGHIJKLMN", require_table = FALSE)

  expect_identical(
    req$url,
    paste0(
      getOption("rairtable.api_url", "https://api.airtable.com/v0"),
      "/appABCDEFGHIJKLMN"
    )
  )
})

test_that("request_airtable_meta supports a custom template", {
  # without_internet() errors with the URL of any request that is attempted
  perform <- function(...) {
    httptest2::without_internet(request_airtable_meta(...))
  }

  expect_error(
    perform(template = "meta/whoami"),
    "meta/whoami",
    class = "httptest2_request"
  )

  expect_error(
    perform(
      template = "meta/bases/{base}/webhooks",
      base = "appABCDEFGHIJKLMN"
    ),
    "meta/bases/appABCDEFGHIJKLMN/webhooks",
    class = "httptest2_request"
  )

  expect_error(
    perform(
      template = "meta/bases/{base}/tables/{table}/fields/{column}",
      base = "https://airtable.com/appABCDEFGHIJKLMN",
      table = "tblABCDEFGHIJKLMN",
      column = "fldABCDEFGHIJKLMN"
    ),
    "meta/bases/appABCDEFGHIJKLMN/tables/tblABCDEFGHIJKLMN/fields/fldABCDEFGHIJKLMN",
    class = "httptest2_request"
  )

  expect_error(perform(), "`meta` must be")
})
