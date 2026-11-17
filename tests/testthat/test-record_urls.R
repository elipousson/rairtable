test_that("parse_url_* functions work with vectors of urls", {
  urls <- c(
    "https://airtable.com/appA/tblB/viwC/recD",
    "https://airtable.com/appA/tblB/viwC/recE",
    "https://airtable.com/appA/tblB/viwC"
  )

  expect_identical(parse_url_record_id(urls), c("recD", "recE", NA_character_))
  expect_identical(parse_url_record_id(urls[[1]]), "recD")
  expect_null(parse_url_record_id(urls[[3]]))
  expect_identical(parse_url_record_id(NA_character_), NA_character_)
})

test_that("update_records and delete_records accept vectors of record urls", {
  withr::local_envvar(AIRTABLE_PAT = "test_pat")
  withr::local_options(rairtable.safely = FALSE)
  atbl <- airtable("tblabc123", "appxyz123", description = "Test base")
  urls <- c(
    "https://airtable.com/appxyz123/tblabc123/viwC/rec1",
    "https://airtable.com/appxyz123/tblabc123/viwC/rec2"
  )
  captured <- new.env()

  httr2::local_mocked_responses(
    function(req) {
      captured$requests <- c(captured$requests, list(req))
      httr2::response_json(body = list(records = list()))
    }
  )

  delete_records(records = urls, airtable = atbl)
  expect_match(
    captured$requests[[1]]$url,
    "records=rec1&records=rec2",
    fixed = TRUE
  )

  update_records(data.frame(Name = c("a", "b")), atbl, records = urls)
  ids <- vapply(
    captured$requests[[2]]$body$data$records,
    function(x) x[["id"]],
    ""
  )
  expect_identical(ids, c("rec1", "rec2"))

  expect_error(
    delete_records(
      records = c(urls[[1]], "https://airtable.com/appxyz123/tblabc123"),
      airtable = atbl
    ),
    "record"
  )
})
