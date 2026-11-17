test_that("airtable_fields_schema works", {
  fields <- airtable_fields_schema(
    list(
      list(name = "a", type = "number", id = "fld1"),
      list(
        name = "b",
        type = "singleSelect",
        id = "fld2",
        description = "A field",
        options = list(choices = list())
      )
    )
  )

  expect_s3_class(fields, "airtable_fields_schema")
  expect_length(fields, 2)
})

test_that("airtable_fields_schema errors for invalid fields", {
  expect_error(
    airtable_fields_schema(list(list(name = "a"))),
    "name"
  )

  expect_error(
    airtable_fields_schema(list("a")),
    "must be a list"
  )

  expect_error(
    airtable_fields_schema(
      list(list(name = "a", type = "number", id = "fld1", foo = "x"))
    ),
    "foo"
  )

  expect_error(airtable_fields_schema("a"))
})
