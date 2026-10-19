test_that("update_records and delete_records use rownames as record IDs", {
  withr::local_envvar(AIRTABLE_PAT = "test_pat")
  withr::local_options(rairtable.safely = FALSE)
  atbl <- airtable("tblabc123", "appxyz123", description = "Test base")
  data <- data.frame(Name = c("a", "b"), row.names = c("rec1", "rec2"))
  captured <- new.env()

  httr2::local_mocked_responses(
    function(req) {
      captured$requests <- c(captured$requests, list(req))
      httr2::response_json(body = list(records = list()))
    }
  )

  expect_identical(get_record_id_col(data), c("rec1", "rec2"))

  update_records(data, atbl)
  ids <- vapply(captured$requests[[1]]$body$data$records, function(x) x[["id"]], "")
  expect_identical(ids, c("rec1", "rec2"))
  expect_named(captured$requests[[1]]$body$data$records[[1]][["fields"]], "Name")

  delete_records(data, atbl)
  expect_match(captured$requests[[2]]$url, "records=rec1&records=rec2", fixed = TRUE)
})

test_that("record ID columns are preferred over rownames", {
  data <- data.frame(
    airtable_record_id = c("rec1", "rec2"),
    row.names = c("rec8", "rec9")
  )

  expect_identical(get_record_id_col(data), c("rec1", "rec2"))
  expect_error(get_record_id_col(data.frame(Name = "a")))
})
