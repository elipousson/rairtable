test_that("airtable errors", {
  expect_error(airtable())

  expect_error(
    airtable(table = "tbl123")
  )

  expect_error(
    airtable(table = c("tbl123", "extra_table"), base = "app123")
  )
})

httptest2::with_mock_dir("airtable", {
  test_that("airtable works", {
    url <- get_rairtable_test_url()
    ids <- parse_airtable_url(url)

    expect_s3_class(
      airtable(
        table = ids$table,
        base = ids$base
      ),
      "airtable"
    )

    expect_s3_class(
      airtable(
        table = url,
        base = ids$base
      ),
      "airtable"
    )

    tables <- get_table_models(base = ids$base)

    expect_s3_class(
      airtable(
        table = tables$name[[1]],
        base = ids$base
      ),
      "airtable"
    )
  })
})

test_that("airtable makes no API request by default", {
  httptest2::without_internet({
    atbl <- airtable(
      table = "tblABCDEFGHIJKLMN",
      base = "appABCDEFGHIJKLMN",
      description = "A real table description"
    )
  })

  expect_s3_class(atbl, "airtable")
  expect_identical(atbl[["description"]], "A real table description")
  expect_null(atbl[["base_name"]])
  expect_identical(atbl[["permissions"]], NULL)
})

test_that("airtable leaves description blank rather than using a name", {
  httptest2::without_internet({
    atbl <- airtable(
      table = "tblABCDEFGHIJKLMN",
      base = "appABCDEFGHIJKLMN",
      name = "Table name",
      base_name = "Base name"
    )
  })

  expect_null(atbl[["description"]])
  expect_identical(atbl[["name"]], "Table name")
  expect_identical(atbl[["base_name"]], "Base name")
})

test_that("airtable lookup = TRUE requests the base listing", {
  expect_error(
    httptest2::without_internet(
      airtable(
        table = "tblABCDEFGHIJKLMN",
        base = "appABCDEFGHIJKLMN",
        lookup = TRUE
      )
    ),
    class = "httptest2_request"
  )
})

mock_lookup <- function(models, env = parent.frame()) {
  testthat::local_mocked_bindings(
    list_bases = function(...) {
      tibble::tibble(
        id = "appABCDEFGHIJKLMN",
        name = "Test base",
        permissionLevel = "create"
      )
    },
    get_table_models = function(base, tables, ...) {
      Filter(
        function(x) x[["name"]] %in% tables || x[["id"]] %in% tables,
        models
      )
    },
    .env = env
  )
}

lookup_models <- list(
  list(
    id = "tblABCDEFGHIJKLMN",
    name = "Tasks",
    description = "Things to do",
    fields = list(list(name = "Name"), list(name = "Done"))
  ),
  list(
    id = "tblZYXWVUTSRQPONML",
    name = "Notes",
    fields = list(list(name = "Text"))
  )
)

test_that("airtable requires a table", {
  expect_error(airtable(base = "appABCDEFGHIJKLMN"))
  expect_error(airtable(table = NULL, base = "appABCDEFGHIJKLMN"))
})

test_that("airtable lookup = TRUE resolves a table name and fills in details", {
  mock_lookup(lookup_models)

  atbl <- airtable("Tasks", "appABCDEFGHIJKLMN", lookup = TRUE)

  expect_identical(atbl[["table"]], "tblABCDEFGHIJKLMN")
  expect_identical(atbl[["name"]], "Tasks")
  expect_identical(atbl[["description"]], "Things to do")
  expect_identical(atbl[["base_name"]], "Test base")
  expect_identical(atbl[["permissions"]], "create")
  expect_identical(atbl[["fields"]], list("Name", "Done"))
})

test_that("airtable lookup = TRUE works with a table ID", {
  mock_lookup(lookup_models)

  atbl <- airtable("tblABCDEFGHIJKLMN", "appABCDEFGHIJKLMN", lookup = TRUE)

  expect_identical(atbl[["name"]], "Tasks")
})

test_that("airtable lookup leaves description blank if the table has none", {
  mock_lookup(lookup_models)

  atbl <- airtable("Notes", "appABCDEFGHIJKLMN", lookup = TRUE)

  expect_null(atbl[["description"]])
  expect_identical(atbl[["name"]], "Notes")
})

test_that("airtable lookup does not override supplied values", {
  mock_lookup(lookup_models)

  atbl <- airtable(
    "Tasks",
    "appABCDEFGHIJKLMN",
    description = "My description",
    base_name = "My base",
    lookup = TRUE
  )

  expect_identical(atbl[["description"]], "My description")
  expect_identical(atbl[["base_name"]], "My base")
})

test_that("airtable lookup = TRUE errors if the table is not in the base", {
  mock_lookup(lookup_models)

  expect_error(
    airtable("Missing", "appABCDEFGHIJKLMN", lookup = TRUE),
    "Can't find a table matching"
  )
})

test_that("airtable lookup with a base-only object does not look up a table", {
  mock_lookup(lookup_models)

  atbl <- airtable(
    "https://airtable.com/appABCDEFGHIJKLMN",
    require_table = FALSE,
    lookup = TRUE
  )

  expect_null(atbl[["table"]])
  expect_identical(atbl[["base_name"]], "Test base")
})
