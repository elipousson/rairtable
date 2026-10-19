test_that("airtable works with table names that need encoding", {
  withr::local_envvar(AIRTABLE_PAT = "test_pat")

  for (name in c("My Table", "Sales (2024)", "Q&A / 2024?", "a.b+c")) {
    atbl <- airtable(name, "appxyz123", description = "Test base")

    expect_identical(atbl[["table"]], name)
    expect_identical(atbl[["name"]], name)
    expect_identical(
      atbl[["request_url"]],
      paste0("https://api.airtable.com/v0/appxyz123/", utils::URLencode(name, reserved = TRUE))
    )
  }
})

test_that("request urls with table names are used as is by requests", {
  withr::local_envvar(AIRTABLE_PAT = "test_pat")
  atbl <- airtable("Sales (2024)", "appxyz123", description = "Test base")
  url <- NULL

  httr2::with_mocked_responses(
    function(req) {
      url <<- req$url
      httr2::response_json(body = list(records = list()))
    },
    list_records(atbl)
  )

  expect_match(url, "appxyz123/Sales%20%282024%29", fixed = TRUE)
})

test_that("check_airtable_api_url compares table names literally", {
  url <- "https://api.airtable.com/v0/appxyz123/Sales%20%282024%29"

  expect_no_error(check_airtable_api_url(url, require_table = "Sales (2024)"))
  expect_error(check_airtable_api_url(url, require_table = "Sales (2023)"))
  expect_error(check_airtable_api_url(url, require_table = "Sales.*"))
})
