httptest2::with_mock_dir("create_field", {
  test_that("create_field works", {

    atbl <- get_rairtable_test_obj()

    atbl_recs <- list_records(atbl)

    atbl_fields <- names(atbl_recs)

    expect_false(
      "Test_create_field" %in% atbl_fields
    )

    create_field(
      atbl,
      name = "Test_create_field"
    )

    tables <- get_table_models(atbl)

    expect_true(
      "Test_create_field" %in% tables[["fields"]][[1]][["name"]]
    )
  })
})

test_that("create_field errors", {
  expect_error(
    create_field(config = "field"),
    '`config` must be a list, not the string "field".'
  )

  expect_error(
    create_field(name = ""),
    '`name` must be a valid name, not the empty string "".'
  )

  expect_error(
    create_field(
      name = "name",
      description = paste0(rep("x", 20001), collapse = "")
    ),
    "`description` must be a string no longer than 20,000 characters."
  )

  expect_error(
    create_field(name = "name", type = "type"),
    "`type` must be one of "
  )
})

test_that("create_field accepts a field config", {
  expect_error(
    create_field(
      airtable("tblABCDEFGHIJKLMN", "appABCDEFGHIJKLMN"),
      config = list(name = "From config", type = "notAType")
    ),
    "type"
  )
})

test_that("update_field requests the field ID or URL", {
  atbl <- airtable("tblABCDEFGHIJKLMN", "appABCDEFGHIJKLMN")
  expected <- "meta/bases/appABCDEFGHIJKLMN/tables/tblABCDEFGHIJKLMN/fields/fldABCDEFGHIJKLMN"

  expect_error(
    httptest2::without_internet(
      update_field(atbl, field = "fldABCDEFGHIJKLMN", name = "New name")
    ),
    expected,
    class = "httptest2_request"
  )

  expect_error(
    httptest2::without_internet(
      update_field(
        atbl,
        field = "https://airtable.com/appABCDEFGHIJKLMN/tblABCDEFGHIJKLMN/fldABCDEFGHIJKLMN",
        name = "New name"
      )
    ),
    expected,
    class = "httptest2_request"
  )

  expect_error(
    httptest2::without_internet(update_field(atbl, field = "Name", name = "x")),
    "`field` must be a field ID"
  )
})
