test_that("download_attachment_field saves files inside path", {
  src <- withr::local_tempfile(fileext = ".txt")
  writeLines("content", src)
  dir <- withr::local_tempdir()
  path <- file.path(dir, "downloads")
  dir.create(path)

  attachments <- data.frame(
    url = paste0("file://", c(src, src)),
    filename = c("../../escape.txt", "a.txt")
  )

  data <- data.frame(id = "rec1")
  data$files <- list(attachments)

  rairtable:::download_attachment_field(
    data,
    field = "files",
    path = path,
    quiet = TRUE
  )

  expect_setequal(list.files(path), c("escape.txt", "a.txt"))
  expect_false(file.exists(file.path(dir, "escape.txt")))
  expect_identical(readLines(file.path(path, "escape.txt")), "content")
})

test_that("download_attachment_field errors if field selects many columns", {
  data <- data.frame(a = 1, b = 2)

  expect_error(
    rairtable:::download_attachment_field(data, field = c("a", "b")),
    "only one"
  )
})
