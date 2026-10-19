test_that("list_records validates sort and fields with a model", {
  withr::local_envvar(AIRTABLE_PAT = "test_pat")
  atbl <- airtable("tblabc123", "appxyz123", description = "Test base")
  model <- list(fields = list(list(name = "Name"), list(name = "Count")))
  url <- NULL

  httr2::local_mocked_responses(
    function(req) {
      url <<- req$url
      httr2::response_json(body = list(records = list()))
    }
  )

  expect_error(list_records(atbl, sort = "Nope", model = model), "sort")
  expect_error(list_records(atbl, fields = "Nope", model = model), "fields")

  list_records(atbl, sort = "Count", direction = "desc", model = model)
  expect_match(url, "sort%5B0%5D%5Bfield%5D=Count", fixed = TRUE)
  expect_match(url, "sort%5B0%5D%5Bdirection%5D=desc", fixed = TRUE)
})
