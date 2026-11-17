test_that("ID predicates require a plausible ID, not just a prefix", {
  expect_true(is_base_id("appABCDEFGHIJKLMN"))
  expect_false(is_base_id("application"))
  expect_false(is_base_id(NULL))

  expect_true(is_table_id("tblABCDEFGHIJKLMN"))
  expect_false(is_table_id("tblSales"))
  expect_true(is_field_id("fldABCDEFGHIJKLMN"))
  expect_false(is_field_id("fields"))
  expect_true(is_record_id("recABCDEFGHIJKLMN"))
  expect_false(is_record_id("recommended"))
})

test_that("get_table_id works with a table ID, URL, or airtable object", {
  atbl <- structure(
    list(base = "appABCDEFGHIJKLMN", table = "tblABCDEFGHIJKLMN"),
    class = "airtable"
  )

  expect_identical(get_table_id(table = "tblABCDEFGHIJKLMN"), "tblABCDEFGHIJKLMN")
  expect_identical(get_table_id(table = atbl), "tblABCDEFGHIJKLMN")
  expect_identical(get_table_id(airtable = atbl), "tblABCDEFGHIJKLMN")
  expect_identical(
    get_table_id(url = "https://airtable.com/appABCDEFGHIJKLMN/tblABCDEFGHIJKLMN"),
    "tblABCDEFGHIJKLMN"
  )
})
