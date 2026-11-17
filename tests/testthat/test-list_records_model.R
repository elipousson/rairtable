test_that("list_records validates sort and fields with a model", {
  withr::local_envvar(AIRTABLE_PAT = "test_pat")
  atbl <- airtable("tblabc123", "appxyz123", description = "Test base")
  model <- list(fields = list(list(name = "Name"), list(name = "Count")))
  url <- NULL

  httr2::local_mocked_responses(
    function(req) {
      url <<- req$url
      httr2::response_json(body = list(records = list()))
    }
  )

  expect_error(list_records(atbl, sort = "Nope", model = model), "sort")
  expect_error(list_records(atbl, fields = "Nope", model = model), "fields")

  list_records(atbl, sort = "Count", direction = "desc", model = model)
  expect_match(url, "sort%5B0%5D%5Bfield%5D=Count", fixed = TRUE)
  expect_match(url, "sort%5B0%5D%5Bdirection%5D=desc", fixed = TRUE)
})

test_that("fill_checkbox_cols sets unchecked checkboxes to FALSE", {
  model <- list(
    fields = list(
      list(name = "Name", type = "singleLineText"),
      list(name = "Done", type = "checkbox"),
      list(name = "Seen", type = "checkbox")
    )
  )
  records <- data.frame(Name = c("a", "b"), Done = c(TRUE, NA))

  out <- fill_checkbox_cols(records, model)
  expect_identical(out$Done, c(TRUE, FALSE))
  expect_identical(out$Seen, c(FALSE, FALSE))
  expect_identical(out$Name, c("a", "b"))

  expect_false("Seen" %in% names(fill_checkbox_cols(records, model, fields = "Done")))
  expect_identical(fill_checkbox_cols(records, NULL), records)
})

test_that("resolve_model prefers explicit, then stored, then looked up models", {
  withr::local_envvar(AIRTABLE_PAT = "test_pat")
  model <- list(
    id = "tblabc123",
    name = "T",
    fields = list(list(name = "Done", type = "checkbox"))
  )
  atbl <- airtable("tblabc123", "appxyz123")

  expect_null(resolve_model(NULL, atbl))
  expect_identical(resolve_model(model, atbl), model)

  atbl_model <- atbl
  atbl_model[["model"]] <- model
  expect_identical(resolve_model(NULL, atbl_model), model)

  calls <- 0
  local_mocked_bindings(
    lookup_table_model = function(...) {
      calls <<- calls + 1
      model
    }
  )
  expect_identical(resolve_model(NULL, atbl, lookup = TRUE), model)
  expect_identical(resolve_model(NULL, NULL, lookup = TRUE, base = "appxyz123", table = "T"), model)
  expect_identical(calls, 2)
  # No lookup when a model is stored
  resolve_model(NULL, atbl_model, lookup = TRUE)
  expect_identical(calls, 2)
})

test_that("list_records fills unchecked checkboxes using lookup", {
  withr::local_envvar(AIRTABLE_PAT = "test_pat")
  model <- list(
    id = "tblabc123",
    fields = list(
      list(name = "Name", type = "singleLineText"),
      list(name = "Done", type = "checkbox")
    )
  )
  local_mocked_bindings(lookup_table_model = function(...) model)
  httr2::local_mocked_responses(
    function(req) {
      httr2::response_json(
        body = list(records = list(
          list(id = "rec1", createdTime = "2026-01-01T00:00:00.000Z", fields = list(Name = "a"))
        ))
      )
    }
  )
  atbl <- airtable("tblabc123", "appxyz123")

  expect_identical(list_records(atbl, lookup = TRUE)$Done, FALSE)
  expect_false("Done" %in% names(list_records(atbl)))
})
