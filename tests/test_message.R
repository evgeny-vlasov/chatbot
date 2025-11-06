# Unit Tests for ChatMessage Class
library(testthat)
library(chatbot)

test_that("ChatMessage creation works", {
  msg <- ChatMessage$new("user", "Hello, world!")

  expect_equal(msg$role, "user")
  expect_equal(msg$content, "Hello, world!")
  expect_true(inherits(msg$timestamp, "POSIXct"))
  expect_equal(msg$metadata, list())
})

test_that("ChatMessage validates role", {
  expect_error(
    ChatMessage$new("invalid_role", "content"),
    "Role must be one of"
  )
})

test_that("ChatMessage accepts valid roles", {
  user_msg <- ChatMessage$new("user", "test")
  assistant_msg <- ChatMessage$new("assistant", "test")
  system_msg <- ChatMessage$new("system", "test")

  expect_equal(user_msg$role, "user")
  expect_equal(assistant_msg$role, "assistant")
  expect_equal(system_msg$role, "system")
})

test_that("ChatMessage to_list works", {
  msg <- ChatMessage$new("user", "test", list(key = "value"))
  msg_list <- msg$to_list()

  expect_type(msg_list, "list")
  expect_equal(msg_list$role, "user")
  expect_equal(msg_list$content, "test")
  expect_equal(msg_list$metadata$key, "value")
})

test_that("ChatMessage with metadata", {
  metadata <- list(source = "test", priority = "high")
  msg <- ChatMessage$new("user", "test", metadata)

  expect_equal(msg$metadata, metadata)
})
