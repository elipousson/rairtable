test_that("make_table_config errors", {
  expect_error(
    make_table_config(),
    "`name` must be a valid name, not `NULL`."
  )

  expect_error(
    make_table_config(name = "name"),
    "`fields` must be a list or data frame."
  )

  expect_error(
    make_table_config(name = "name", fields = list(name = "field")),
    '`field` must have the names "name" and "type".'
  )
})

test_that("make_table_config works", {
  expect_identical(
    make_table_config(
      name = "table",
      fields = list(list(name = "field", type = "singleLineText"))
    ),
    list(
      name = "table",
      fields = list(list(name = "field", type = "singleLineText"))
    )
  )
})

test_that("make_table_config drops names so fields serialize as a JSON array", {
  fields <- list(
    a = list(name = "a", type = "singleLineText"),
    b = list(name = "b", type = "checkbox")
  )
  config <- make_table_config(name = "table", fields = fields)

  expect_null(names(config$fields))
  expect_match(
    as.character(jsonlite::toJSON(config, auto_unbox = TRUE)),
    '"fields":[{',
    fixed = TRUE
  )
})

test_that("data_as_fields maps column classes to field types", {
  df <- data.frame(
    name = c("a", "b"),
    long = c(strrep("x", 101), NA),
    n = 1:2,
    x = c(1.5, 2),
    flag = c(TRUE, FALSE),
    when = as.Date(c("2026-01-01", NA)),
    f = factor(c("u", "v")),
    stringsAsFactors = FALSE
  )
  fields <- data_as_fields(df)

  expect_null(names(fields))
  expect_identical(
    vapply(fields, `[[`, "", "type"),
    c(
      "singleLineText", "multilineText", "number", "number",
      "checkbox", "date", "singleSelect"
    )
  )
  expect_identical(fields[[3]]$options$precision, 0)
  expect_identical(
    vapply(fields[[7]]$options$choices, `[[`, "", "name"),
    c("u", "v")
  )

  config <- make_table_config(name = "t", data = df)
  expect_length(config$fields, 7)
  expect_match(
    as.character(jsonlite::toJSON(config, auto_unbox = TRUE)),
    '"fields":[{',
    fixed = TRUE
  )
})

test_that("data_as_fields warns for a non-text primary field", {
  expect_warning(data_as_fields(data.frame(n = 1:2, s = "a")), "primary field")
  expect_warning(data_as_fields(data.frame(s = "a", l = I(list(1)))), "singleLineText")
  expect_error(data_as_fields(data.frame()), "at least one column")
})
