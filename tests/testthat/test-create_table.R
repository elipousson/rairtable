httptest2::with_mock_dir("create_table", {
  test_that("create_table and update_table work", {
    atbl <- get_rairtable_test_obj()
    random_abb <- sample(state.abb, 1)

    atbl_tbl <- create_table(
      # airtable = atbl,
      base = atbl$base,
      name = random_abb,
      fields = list(list(name = "Primary field", type = "singleLineText"))
    )

    expect_named(
      atbl_tbl,
      c("id", "name", "primaryFieldId", "fields", "views")
    )

    expect_identical(
      atbl_tbl$fields[[1]]$name,
      "Primary field"
    )

    atbl_tbl_update <- update_table(
      base = atbl$base,
      table = atbl_tbl$id,
      name = paste0("updated", random_abb)
    )

    expect_identical(
      atbl_tbl_update$name,
      paste0("updated", random_abb)
    )
  })
})

test_that("create_table and update_table report the table url", {
  withr::local_envvar(AIRTABLE_PAT = "test_pat")
  atbl <- airtable("tblabc123", "appxyz123", description = "Test base")

  httr2::local_mocked_responses(
    function(req) {
      httr2::response_json(
        url = req$url,
        body = list(id = "tblnew", name = "New")
      )
    }
  )

  msg <- testthat::capture_messages(
    create_table(
      atbl,
      name = "New",
      fields = list(list(name = "Name", type = "singleLineText"))
    )
  )
  expect_match(
    paste(msg, collapse = "\n"),
    "https://airtable.com/appxyz123/tblnew",
    fixed = TRUE
  )

  msg <- testthat::capture_messages(
    update_table(atbl, name = "Updated", table = "tblnew")
  )
  expect_match(
    paste(msg, collapse = "\n"),
    "https://airtable.com/appxyz123/tblnew",
    fixed = TRUE
  )
})
