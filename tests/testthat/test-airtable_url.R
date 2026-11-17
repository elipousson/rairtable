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

  atbl <- get_rairtable_test_obj()

  expect_null(
    check_airtable_api_url(atbl[["request_url"]])
  )
})


test_that("is_airtable_url and is_airtable_api_url reject lookalike hosts", {
  expect_false(is_airtable_url(
    "https://airtable.com.example.org/appABCDEFGHIJKLMN"
  ))
  expect_false(is_airtable_url("https://airtableXcom/appABCDEFGHIJKLMN"))
  expect_true(is_airtable_url("https://airtable.com/appABCDEFGHIJKLMN"))
  expect_false(is_airtable_url("https://airtable.com/shrABCDEFGHIJKLMN"))
  expect_true(
    is_airtable_url(
      "https://airtable.com/shrABCDEFGHIJKLMN",
      allow_shared = TRUE
    )
  )
  expect_false(is_airtable_api_url("https://api.airtable.com.example.org/v0"))
  expect_true(is_airtable_api_url(
    "https://api.airtable.com/v0/appABCDEFGHIJKLMN"
  ))
})

test_that("parse_url_record_id is vectorized and ignores view parameters", {
  urls <- c(
    "https://airtable.com/appABCDEFGHIJKLMN/tblABCDEFGHIJKLMN/viwABCDEFGHIJKLMN/recAAAAAAAAAAAAAA",
    "https://airtable.com/appABCDEFGHIJKLMN/tblABCDEFGHIJKLMN/recBBBBBBBBBBBBBB?blocks=hide",
    "https://airtable.com/appABCDEFGHIJKLMN/tblABCDEFGHIJKLMN?view=recCCCCCCCCCCCCCC"
  )

  expect_identical(
    parse_url_record_id(urls),
    c("recAAAAAAAAAAAAAA", "recBBBBBBBBBBBBBB", NA_character_)
  )

  expect_identical(
    get_record_ids_from_urls(urls[1:2]),
    c("recAAAAAAAAAAAAAA", "recBBBBBBBBBBBBBB")
  )

  expect_error(
    get_record_ids_from_urls(urls),
    "must be record IDs or URLs with a record ID"
  )
})

test_that("parse_airtable_url parses base-only URLs", {
  expect_identical(
    parse_airtable_url("https://airtable.com/appABCDEFGHIJKLMN"),
    list(base = "appABCDEFGHIJKLMN")
  )
  expect_identical(
    parse_airtable_url("https://airtable.com/appABCDEFGHIJKLMN?blocks=hide"),
    list(base = "appABCDEFGHIJKLMN")
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
