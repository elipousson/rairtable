test_that("deprecated arguments warn", {
  withr::local_envvar(AIRTABLE_PAT = "test_pat")
  withr::local_options(rairtable.safely = FALSE)
  atbl <- airtable("tblabc123", "appxyz123", description = "Test base")

  httr2::local_mocked_responses(
    function(req) httr2::response_json(body = list(records = list()))
  )

  lifecycle::expect_deprecated(read_airtable(atbl, max_rows = 10))

  lifecycle::expect_deprecated(
    insert_records(data.frame(Name = "a"), atbl, batch_size = 10)
  )

  lifecycle::expect_deprecated(
    create_records(data.frame(Name = "a"), atbl, batch_size = 10)
  )

  lifecycle::expect_deprecated(
    delete_records(records = "rec1", airtable = atbl, batch_size = 10)
  )
})

test_that("deprecated arguments do not warn when they are not supplied", {
  withr::local_envvar(AIRTABLE_PAT = "test_pat")
  withr::local_options(
    rairtable.safely = FALSE,
    lifecycle_verbosity = "warning"
  )
  atbl <- airtable("tblabc123", "appxyz123", description = "Test base")

  httr2::local_mocked_responses(
    function(req) httr2::response_json(body = list(records = list()))
  )

  expect_no_warning(read_airtable(atbl))
  expect_no_warning(create_records(data.frame(Name = "a"), atbl))
  expect_no_warning(delete_records(records = "rec1", airtable = atbl))
})
