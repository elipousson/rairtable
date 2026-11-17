httptest2::with_mock_dir("read_airtable", {
  test_that("read_airtable works", {

    atbl <- get_rairtable_test_obj()

    expect_error(
      read_airtable()
    )

    with_options(
      list("rairtable.default_pat" = "RAIRTABLE_TEST_PAT_TEXT"),
      {
        expect_error(
          read_airtable(atbl, id_to_col = "")
        )

        insert_records(
          data.frame(
            "Name" = "Test"
          ),
          atbl
        )

        atbl_df <- read_airtable(atbl)

        record_df <- list_records(atbl)

        id_col <- getOption("rairtable.id_col", "airtable_record_id")
        records <- atbl_df[!is.na(atbl_df$Name), ][[id_col]]

        expect_s3_class(
          get_record(
            atbl,
            record = records[[1]]
          ),
          "data.frame"
        )

        delete_records(
          airtable = atbl,
          records = records[[length(records)]],
          safely = FALSE
        )
      }
    )

    expect_s3_class(
      atbl_df,
      "data.frame"
    )

    expect_s3_class(
      record_df,
      "data.frame"
    )
  })
})
