# Unit Tests for ConversationManager Class
library(testthat)
library(chatbot)

test_that("ConversationManager initialization", {
  conv <- ConversationManager$new()

  expect_equal(length(conv$messages), 0)
  expect_equal(conv$max_history, 100)
  expect_null(conv$system_prompt)
})

test_that("ConversationManager with system prompt", {
  conv <- ConversationManager$new(system_prompt = "You are helpful.")

  expect_equal(length(conv$messages), 1)
  expect_equal(conv$messages[[1]]$role, "system")
  expect_equal(conv$messages[[1]]$content, "You are helpful.")
})

test_that("Adding messages to conversation", {
  conv <- ConversationManager$new()

  conv$add_message("user", "Hello")
  conv$add_message("assistant", "Hi there!")

  expect_equal(length(conv$messages), 2)
  expect_equal(conv$messages[[1]]$role, "user")
  expect_equal(conv$messages[[2]]$role, "assistant")
})

test_that("Conversation history trimming", {
  conv <- ConversationManager$new(max_history = 5)

  for (i in 1:10) {
    conv$add_message("user", sprintf("Message %d", i))
  }

  expect_equal(length(conv$messages), 5)
  # Should keep most recent messages
  expect_equal(conv$messages[[5]]$content, "Message 10")
})

test_that("System prompt preserved during trimming", {
  conv <- ConversationManager$new(max_history = 5, system_prompt = "System")

  for (i in 1:10) {
    conv$add_message("user", sprintf("Message %d", i))
  }

  # Should keep system message plus recent messages
  expect_true(any(sapply(conv$messages, function(m) m$role == "system")))
  expect_lte(length(conv$messages), 5)
})

test_that("get_api_messages formats correctly", {
  conv <- ConversationManager$new()
  conv$add_message("user", "Hello")
  conv$add_message("assistant", "Hi")

  api_msgs <- conv$get_api_messages()

  expect_equal(length(api_msgs), 2)
  expect_equal(api_msgs[[1]]$role, "user")
  expect_equal(api_msgs[[1]]$content, "Hello")
  expect_equal(api_msgs[[2]]$role, "assistant")
  expect_equal(api_msgs[[2]]$content, "Hi")
})

test_that("clear() removes messages except system prompt", {
  conv <- ConversationManager$new(system_prompt = "System")
  conv$add_message("user", "Hello")
  conv$add_message("assistant", "Hi")

  conv$clear()

  expect_equal(length(conv$messages), 1)
  expect_equal(conv$messages[[1]]$role, "system")
})

test_that("summary() provides correct counts", {
  conv <- ConversationManager$new(system_prompt = "System")
  conv$add_message("user", "Hello")
  conv$add_message("assistant", "Hi")

  summary_text <- conv$summary()

  expect_true(grepl("3 messages", summary_text))
  expect_true(grepl("1 user", summary_text))
  expect_true(grepl("1 assistant", summary_text))
  expect_true(grepl("1 system", summary_text))
})
