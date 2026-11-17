comment_fixture <- function(id, text = "hello") {
  list(
    id = id,
    text = text,
    createdTime = "2020-01-01T00:00:00.000Z",
    author = list(id = "usr1", email = "a@example.com", name = "A")
  )
}

test_that("comments_to_tibble returns one row per comment", {
  one <- comments_to_tibble(list(comment_fixture("com1")))
  expect_s3_class(one, "tbl_df")
  expect_identical(nrow(one), 1L)
  expect_identical(one[["id"]], "com1")
  expect_identical(one[["author"]][[1]][["name"]], "A")

  two <- comments_to_tibble(list(
    comment_fixture("com1"),
    comment_fixture("com2", "yo")
  ))
  expect_identical(two[["id"]], c("com1", "com2"))
  expect_identical(two[["text"]], c("hello", "yo"))

  expect_identical(nrow(comments_to_tibble(list())), 0L)
})

test_that("list_comments, create_comment, and delete_comment work", {
  withr::local_envvar(AIRTABLE_PAT = "test_pat")
  atbl <- airtable("tblabc123", "appxyz123", description = "Test base")

  httr2::local_mocked_responses(
    function(req) {
      if (identical(httr2::req_get_method(req), "POST")) {
        return(httr2::response_json(body = comment_fixture("comnew")))
      }

      if (identical(httr2::req_get_method(req), "DELETE")) {
        return(httr2::response_json(
          body = list(id = "comabc123", deleted = TRUE)
        ))
      }

      httr2::response_json(
        body = list(comments = list(comment_fixture("com1")))
      )
    }
  )

  comments <- list_comments(atbl, record = "recabc123")
  expect_identical(comments[["id"]], "com1")

  created <- create_comment(atbl, record = "recabc123", text = "hi")
  expect_identical(created[["id"]], "comnew")
  expect_identical(nrow(created), 1L)

  deleted <- delete_comment(atbl, record = "recabc123", comment = "comabc123")
  expect_identical(deleted[["deleted"]], TRUE)
})

test_that("comment functions use the supplied token", {
  skip_if_not("redacted" %in% names(formals(httr2::req_get_headers)))
  withr::local_envvar(AIRTABLE_PAT = "env_pat")
  atbl <- airtable("tblabc123", "appxyz123", description = "Test base")
  auth <- character()

  httr2::local_mocked_responses(
    function(req) {
      auth <<- c(
        auth,
        httr2::req_get_headers(req, redacted = "reveal")[["Authorization"]]
      )

      switch(
        httr2::req_get_method(req),
        "POST" = httr2::response_json(body = comment_fixture("comnew")),
        "DELETE" = httr2::response_json(body = list(id = "comabc123")),
        httr2::response_json(
          body = list(comments = list(comment_fixture("com1")))
        )
      )
    }
  )

  list_comments(atbl, record = "recabc123", token = "arg_pat")
  create_comment(atbl, record = "recabc123", text = "hi", token = "arg_pat")
  delete_comment(
    atbl,
    record = "recabc123",
    comment = "comabc123",
    token = "arg_pat"
  )
  list_comments(atbl, record = "recabc123")

  expect_identical(auth, c(rep("Bearer arg_pat", 3), "Bearer env_pat"))
})
