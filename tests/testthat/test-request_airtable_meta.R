capture_meta_request <- function(...) {
  withr::local_envvar(AIRTABLE_PAT = "test_pat")
  captured <- new.env()

  httr2::with_mocked_responses(
    function(req) {
      captured$method <- req$method
      captured$url <- req$url
      httr2::response_json(body = list())
    },
    request_airtable_meta(...)
  )

  captured
}

test_that("request_airtable_meta works with a template", {
  req <- capture_meta_request(
    base = "appabc123",
    template = "meta/bases/{base}/tables"
  )

  expect_identical(
    req$url,
    "https://api.airtable.com/v0/meta/bases/appabc123/tables"
  )

  withr::local_envvar(AIRTABLE_PAT = "test_pat")

  expect_error(
    request_airtable_meta(template = "meta/bases/{base}/tables"),
    "base"
  )

  expect_error(
    request_airtable_meta(
      base = "appabc123",
      template = "meta/bases/{base}/tables/{table}"
    ),
    "table"
  )
})

test_that("request_airtable_meta builds urls for each meta value", {
  expect_identical(
    capture_meta_request(meta = "list_base")$url,
    "https://api.airtable.com/v0/meta/bases"
  )

  expect_identical(
    capture_meta_request(meta = "schema_base", base = "appabc123")$url,
    "https://api.airtable.com/v0/meta/bases/appabc123/tables"
  )

  update_req <- capture_meta_request(
    meta = "update_table", base = "appabc123", table = "tblabc123",
    method = "PATCH", data = list(name = "x")
  )

  expect_identical(update_req$method, "PATCH")
  expect_identical(
    update_req$url,
    "https://api.airtable.com/v0/meta/bases/appabc123/tables/tblabc123"
  )
})
