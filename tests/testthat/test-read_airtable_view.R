test_that("list_records and read_airtable keep the view when fields are supplied", {
  withr::local_envvar(AIRTABLE_PAT = "test_pat")
  atbl <- airtable(
    "tblabc123", "appxyz123",
    view = "viwabc123",
    description = "Test base"
  )
  urls <- character()

  httr2::with_mocked_responses(
    function(req) {
      urls <<- c(urls, req$url)
      httr2::response_json(body = list(records = list()))
    },
    {
      list_records(atbl)
      list_records(atbl, fields = c("Name", "Other"))
      read_airtable(atbl, fields = "Name")
    }
  )

  expect_length(urls, 3)
  expect_match(urls, "view=viwabc123", fixed = TRUE)
  expect_match(urls[2:3], "fields%5B%5D=Name", fixed = TRUE)
  expect_match(urls[2], "fields%5B%5D=Other", fixed = TRUE)
})
