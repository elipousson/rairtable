test_that("is_airtable_url works", {
  expect_true(
    is_airtable_url("https://airtable.com")
  )
  expect_false(
    is_airtable_url("https://airtable.co")
  )
  expect_true(
    is_airtable_url(
      "https://custom.airtable.com",
      "https://custom.airtable.com"
    )
  )
})

test_that("is_airtable_api_url works", {
  expect_true(
    is_airtable_api_url("https://api.airtable.com/v0")
  )
  expect_false(
    is_airtable_api_url("https://api.airtable.co")
  )
  expect_true(
    is_airtable_api_url(
      "https://custom.airtable.com",
      "https://custom.airtable.com"
    )
  )
})


test_that("check_airtable_url works", {
  expect_error(
    check_airtable_url()
  )
  expect_null(
    check_airtable_url(NULL, allow_null = TRUE)
  )
  expect_null(
    check_airtable_url("https://airtable.com")
  )
  expect_error(
    check_airtable_url("https://api.airtable.com")
  )
  expect_null(
    check_airtable_url(
      "https://custom.airtable.com",
      "https://custom.airtable.com"
    )
  )
})


test_that("check_airtable_api_url works", {
  expect_error(
    check_airtable_api_url()
  )
  expect_error(
    check_airtable_api_url("https://api.airtable.com")
  )

  skip_if_no_pat()

  atbl <- get_rairtable_test_obj()

  expect_null(
    check_airtable_api_url(atbl[["request_url"]])
  )
})

test_that("parse_airtable_url parses base urls without a trailing slash", {
  expect_identical(
    parse_airtable_url("https://airtable.com/appxyz123"),
    list(base = "appxyz123")
  )

  expect_identical(
    parse_airtable_url("https://airtable.com/appxyz123?foo=bar"),
    list(base = "appxyz123")
  )

  expect_identical(
    parse_airtable_url("https://airtable.com/appxyz123/tblabc123/viwdef456"),
    list(base = "appxyz123", table = "tblabc123", view = "viwdef456")
  )
})
