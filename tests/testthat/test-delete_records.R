httptest2::with_mock_dir("delete_records", {
  test_that("delete_records works", {
    atbl <- get_rairtable_test_obj()

    initial_records <- read_airtable(atbl)

    test_records <-
      data.frame(
        "Name" = c("Record 1", "Record 2"),
        "Notes" = c("Notes 1", "Notes 2")
      )

    insert_records(test_records, atbl)

    records_updated <- read_airtable(atbl)

    expect_identical(
      nrow(records_updated),
      nrow(initial_records) + nrow(test_records)
    )

    records_deleted <-
      records_updated[records_updated$Name %in% test_records$Name, ]

    delete_records(records_deleted, airtable = atbl, safely = FALSE)

    expect_identical(
      nrow(initial_records),
      nrow(records_updated) - nrow(records_deleted)
    )
  })
})

test_that("delete_records builds a multi-record request with return_data", {
  atbl <- airtable("tblABCDEFGHIJKLMN", "appABCDEFGHIJKLMN")

  expect_error(
    httptest2::without_internet(
      delete_records(
        airtable = atbl,
        records = c("recAAAAAAAAAAAAAA", "recBBBBBBBBBBBBBB"),
        safely = FALSE,
        return_data = FALSE
      )
    ),
    "records=recAAAAAAAAAAAAAA&records=recBBBBBBBBBBBBBB",
    class = "httptest2_request"
  )

  expect_error(
    httptest2::without_internet(
      delete_records(
        airtable = atbl,
        records = c(
          "https://airtable.com/appABCDEFGHIJKLMN/tblABCDEFGHIJKLMN/recAAAAAAAAAAAAAA",
          "https://airtable.com/appABCDEFGHIJKLMN/tblABCDEFGHIJKLMN/recBBBBBBBBBBBBBB"
        ),
        safely = FALSE
      )
    ),
    "records=recAAAAAAAAAAAAAA&records=recBBBBBBBBBBBBBB",
    class = "httptest2_request"
  )
})
