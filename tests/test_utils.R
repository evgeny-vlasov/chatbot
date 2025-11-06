# Unit Tests for Utility Functions
library(testthat)
library(chatbot)

test_that("count_tokens approximates correctly", {
  short_text <- "Hello"
  long_text <- paste(rep("word", 100), collapse = " ")

  count_short <- count_tokens(short_text)
  count_long <- count_tokens(long_text)

  expect_true(count_short > 0)
  expect_true(count_long > count_short)
  expect_true(count_long > 50)  # Should be significant for 100 words
})

test_that("truncate_text works", {
  long_text <- paste(rep("This is a sentence. ", 100), collapse = "")

  truncated <- truncate_text(long_text, max_tokens = 20)

  expect_true(nchar(truncated) < nchar(long_text))
  expect_true(grepl("\\.\\.\\.$", truncated))  # Ends with ...
})

test_that("truncate_text doesn't truncate short text", {
  short_text <- "Hello, world!"

  result <- truncate_text(short_text, max_tokens = 100)

  expect_equal(result, short_text)
})

test_that("format_conversation works", {
  conv <- ConversationManager$new()
  conv$add_message("user", "Hello")
  conv$add_message("assistant", "Hi there!")

  formatted <- format_conversation(conv)

  expect_true(grepl("USER", formatted))
  expect_true(grepl("ASSISTANT", formatted))
  expect_true(grepl("Hello", formatted))
  expect_true(grepl("Hi there!", formatted))
})

test_that("format_conversation excludes system by default", {
  conv <- ConversationManager$new(system_prompt = "System prompt")
  conv$add_message("user", "Hello")

  formatted <- format_conversation(conv, include_system = FALSE)

  expect_false(grepl("System prompt", formatted))
  expect_true(grepl("Hello", formatted))
})

test_that("format_conversation includes system when requested", {
  conv <- ConversationManager$new(system_prompt = "System prompt")
  conv$add_message("user", "Hello")

  formatted <- format_conversation(conv, include_system = TRUE)

  expect_true(grepl("SYSTEM", formatted))
  expect_true(grepl("System prompt", formatted))
})

test_that("save and load conversation works", {
  conv <- ConversationManager$new()
  conv$add_message("user", "Hello")
  conv$add_message("assistant", "Hi!")

  temp_file <- tempfile(fileext = ".json")

  save_conversation(conv, temp_file)
  expect_true(file.exists(temp_file))

  loaded_conv <- load_conversation(temp_file)
  expect_equal(length(loaded_conv$messages), 2)
  expect_equal(loaded_conv$messages[[1]]$content, "Hello")
  expect_equal(loaded_conv$messages[[2]]$content, "Hi!")

  unlink(temp_file)
})
