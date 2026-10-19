test_that("airtable_base makes one request for base info and passes token", {
  withr::local_envvar(AIRTABLE_PAT = "env_pat")
  urls <- character()

  schema <- list(
    tables = list(
      list(
        id = "tbl1", name = "One", primaryFieldId = "fld1",
        description = "Table description",
        fields = list(list(id = "fld1", name = "Name", type = "singleLineText"))
      ),
      list(
        id = "tbl2", name = "Two", primaryFieldId = "fld2",
        fields = list(list(id = "fld2", name = "Title", type = "singleLineText"))
      ),
      list(
        id = "tbl3", name = "Three", primaryFieldId = "fld3",
        fields = list(list(id = "fld3", name = "Item", type = "singleLineText"))
      )
    )
  )

  httr2::local_mocked_responses(
    function(req) {
      urls <<- c(urls, req$url)

      if (grepl("/tables$", req$url)) {
        return(httr2::response_json(body = schema))
      }

      httr2::response_json(
        body = list(
          bases = list(
            list(id = "appxyz123", name = "Test base", permissionLevel = "create")
          )
        )
      )
    }
  )

  base <- airtable_base("appxyz123", token = "arg_pat")

  expect_named(base, c("base", "schema", "tables"))
  expect_s3_class(base[["schema"]], "airtable_base_schema")
  expect_length(base[["tables"]], 3)
  expect_named(base[["tables"]], c("One", "Two", "Three"))
  expect_identical(base[["tables"]][["One"]][["description"]], "Test base")
  expect_identical(base[["tables"]][["Two"]][["description"]], "Test base")
  expect_identical(base[["tables"]][["Two"]][["fields"]], list("Title"))

  # one request for the schema and one for the base name
  expect_length(urls, 2)
})
