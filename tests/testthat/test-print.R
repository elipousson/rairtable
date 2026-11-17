test_that("print methods show the primary class and escape braces in names", {
  atbl <- airtable(
    "tblabc123",
    "appxyz123",
    base_name = "Test base",
    description = "Table description"
  )
  out <- cli::cli_fmt(print(atbl))
  expect_match(out[[1]], "<airtable>", fixed = TRUE)
  # The base name is shown in the header and the table description is shown
  # separately (not substituted for each other)
  expect_match(paste(out, collapse = "\n"), "\"Test base\"")
  expect_match(paste(out, collapse = "\n"), "Description: Table description")

  fields <- vctrs::new_vctr(
    list(
      list(name = "Budget {2024}", id = "fld1", type = "number"),
      list(name = "{oops}", id = "fld2", type = "singleLineText")
    ),
    class = "airtable_fields_schema"
  )

  schema <- vctrs::new_vctr(
    list(list(name = "Budget {2024}", id = "tbl1")),
    class = "airtable_base_schema"
  )

  expect_no_error(out_fields <- cli::cli_fmt(print(fields)))
  expect_match(
    paste(out_fields, collapse = "\n"),
    "Budget {2024}",
    fixed = TRUE
  )
  expect_match(paste(out_fields, collapse = "\n"), "{oops}", fixed = TRUE)

  expect_no_error(out_schema <- cli::cli_fmt(print(schema)))
  expect_match(out_schema[[1]], "<airtable_base_schema>", fixed = TRUE)
  expect_match(
    paste(out_schema, collapse = "\n"),
    "Budget {2024}",
    fixed = TRUE
  )
})
