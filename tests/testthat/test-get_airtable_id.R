test_that("get_table_id works with a table ID, URL, or airtable object", {
  atbl <- structure(
    list(base = "appABCDEFGHIJKLMN", table = "tblABCDEFGHIJKLMN"),
    class = "airtable"
  )

  expect_identical(
    get_table_id(table = "tblABCDEFGHIJKLMN"),
    "tblABCDEFGHIJKLMN"
  )
  expect_identical(get_table_id(table = atbl), "tblABCDEFGHIJKLMN")
  expect_identical(get_table_id(airtable = atbl), "tblABCDEFGHIJKLMN")
  expect_identical(
    get_table_id(
      url = "https://airtable.com/appABCDEFGHIJKLMN/tblABCDEFGHIJKLMN"
    ),
    "tblABCDEFGHIJKLMN"
  )
})

test_that("get_table_id and get_base_id work with airtable objects", {
  atbl <- airtable("tblabc123", "appxyz123", description = "Test base")

  expect_identical(get_table_id(table = atbl), "tblabc123")
  expect_identical(get_table_id(airtable = atbl), "tblabc123")
  expect_identical(get_base_id(base = atbl), "appxyz123")
  expect_identical(get_base_id(airtable = atbl), "appxyz123")
})

test_that("get_*_id functions parse urls", {
  url <- "https://airtable.com/appxyz123/tblabc123/viwdef456"

  expect_identical(get_base_id(url = url), "appxyz123")
  expect_identical(get_table_id(url = url), "tblabc123")
  expect_error(get_table_id(table = 1))
})
