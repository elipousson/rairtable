test_that("read_airtable and list_records return an empty data frame", {
  withr::local_envvar(AIRTABLE_PAT = "test_pat")
  atbl <- airtable("tblabc123", "appxyz123", description = "Test base")

  httr2::with_mocked_responses(
    function(req) httr2::response_json(body = list(records = list())),
    {
      records <- read_airtable(atbl)
      listed <- list_records(atbl)
      no_metadata <- list_records(atbl, metadata = NULL)
    }
  )

  expect_s3_class(records, "data.frame")
  expect_identical(nrow(records), 0L)
  expect_identical(names(records), "airtable_record_id")
  expect_identical(nrow(listed), 0L)
  expect_identical(names(listed), c("airtable_record_id", "createdTime"))
  expect_identical(nrow(no_metadata), 0L)
})

test_that("read_airtable combines empty and non-empty pages", {
  withr::local_envvar(AIRTABLE_PAT = "test_pat")
  atbl <- airtable("tblabc123", "appxyz123", description = "Test base")
  n_requests <- 0

  httr2::with_mocked_responses(
    function(req) {
      n_requests <<- n_requests + 1

      if (n_requests == 1) {
        return(httr2::response_json(
          body = list(records = list(), offset = "o1")
        ))
      }

      httr2::response_json(
        body = list(
          records = list(
            list(
              id = "rec1",
              createdTime = "2020-01-01T00:00:00.000Z",
              fields = list(Name = "a")
            )
          )
        )
      )
    },
    records <- list_records(atbl)
  )

  expect_identical(nrow(records), 1L)
  expect_identical(records[["Name"]], "a")
})
