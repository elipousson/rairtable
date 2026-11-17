test_that("typecast defaults to FALSE for every record request", {
  withr::local_envvar(AIRTABLE_PAT = "test_pat")
  atbl <- airtable("tblabc123", "appxyz123", description = "Test base")
  bodies <- list()

  httr2::local_mocked_responses(
    function(req) {
      bodies <<- c(bodies, list(req$body$data))
      httr2::response_json(body = list(records = list()))
    }
  )

  req_create_records(airtable = atbl, data = data.frame(Name = "a"))
  req_update_record(
    req = request_airtable(atbl),
    record = "rec1",
    data = data.frame(Name = "a")
  )
  req_update_records(
    airtable = atbl,
    records = "rec1",
    data = data.frame(Name = "a")
  )

  expect_identical(
    vapply(bodies, function(x) x[["typecast"]], NA),
    c(FALSE, FALSE, FALSE)
  )
})
