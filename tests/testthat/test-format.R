test_that("format works for airtable objects", {
  atbl <- airtable("tblabc123", "appxyz123", description = "Test base")

  expect_type(format(atbl), "character")
  expect_length(format(atbl), length(atbl))

  schema <- vctrs::new_vctr(
    list(list(name = "a", id = "tbl1")),
    class = "airtable_base_schema"
  )

  expect_type(format(schema), "character")
  expect_length(format(schema), 1)
})
