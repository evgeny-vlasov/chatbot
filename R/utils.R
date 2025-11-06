#' Utility Functions for Chatbot Package
#'
#' @description
#' Helper functions for chatbot operations.
#'
#' @name utils
NULL


#' Count Tokens (Approximate)
#'
#' @description
#' Provides a rough estimate of token count for a text string.
#' Note: This is an approximation; actual token counts may vary by model.
#'
#' @param text Character string to count tokens for
#' @return Integer estimate of token count
#'
#' @examples
#' count_tokens("Hello, world!")
#'
#' @export
count_tokens <- function(text) {
  # Rough approximation: ~4 characters per token
  # This is a simplified estimate
  words <- strsplit(text, "\\s+")[[1]]
  chars <- nchar(text)

  # Use a weighted average of word count and character count
  round((length(words) * 1.3 + chars / 4) / 2)
}


#' Truncate Text to Token Limit
#'
#' @description
#' Truncate text to approximately fit within a token limit.
#'
#' @param text Character string to truncate
#' @param max_tokens Maximum number of tokens
#' @return Truncated character string
#'
#' @examples
#' truncate_text("This is a long text...", max_tokens = 10)
#'
#' @export
truncate_text <- function(text, max_tokens) {
  current_tokens <- count_tokens(text)

  if (current_tokens <= max_tokens) {
    return(text)
  }

  # Rough character estimate
  target_chars <- round(max_tokens * 4)
  truncated <- substr(text, 1, target_chars)

  # Try to end at a word boundary
  last_space <- max(gregexpr(" ", truncated)[[1]])
  if (last_space > 0 && last_space > target_chars * 0.8) {
    truncated <- substr(truncated, 1, last_space)
  }

  paste0(truncated, "...")
}


#' Format Conversation for Display
#'
#' @description
#' Format a conversation history as readable text.
#'
#' @param conversation ConversationManager object or list of messages
#' @param include_system Include system messages (default: FALSE)
#' @return Character string with formatted conversation
#'
#' @examples
#' \dontrun{
#' bot <- create_chatbot("openai")
#' bot$chat("Hello!")
#' format_conversation(bot$conversation)
#' }
#'
#' @export
format_conversation <- function(conversation, include_system = FALSE) {
  if (inherits(conversation, "ConversationManager")) {
    messages <- conversation$messages
  } else {
    messages <- conversation
  }

  lines <- character()

  for (msg in messages) {
    if (!include_system && msg$role == "system") {
      next
    }

    role_label <- switch(
      msg$role,
      "user" = "USER",
      "assistant" = "ASSISTANT",
      "system" = "SYSTEM"
    )

    timestamp <- format(msg$timestamp, "%H:%M:%S")
    lines <- c(lines, sprintf("[%s] %s:", timestamp, role_label))
    lines <- c(lines, msg$content)
    lines <- c(lines, "")
  }

  paste(lines, collapse = "\n")
}


#' Save Conversation to File
#'
#' @description
#' Save conversation history to a JSON file.
#'
#' @param conversation ConversationManager object
#' @param file_path Path to save the JSON file
#'
#' @examples
#' \dontrun{
#' bot <- create_chatbot("openai")
#' bot$chat("Hello!")
#' save_conversation(bot$conversation, "conversation.json")
#' }
#'
#' @export
save_conversation <- function(conversation, file_path) {
  messages <- conversation$get_messages()
  json <- jsonlite::toJSON(messages, pretty = TRUE, auto_unbox = TRUE)
  writeLines(json, file_path)
  message(sprintf("Conversation saved to: %s", file_path))
}


#' Load Conversation from File
#'
#' @description
#' Load conversation history from a JSON file.
#'
#' @param file_path Path to the JSON file
#' @param max_history Maximum history for the conversation manager
#' @return ConversationManager object
#'
#' @examples
#' \dontrun{
#' conversation <- load_conversation("conversation.json")
#' }
#'
#' @export
load_conversation <- function(file_path, max_history = 100) {
  json <- readLines(file_path, warn = FALSE)
  messages <- jsonlite::fromJSON(json)

  # Extract system prompt if present
  system_prompt <- NULL
  if (nrow(messages) > 0 && messages$role[1] == "system") {
    system_prompt <- messages$content[1]
  }

  # Create conversation manager
  conv <- ConversationManager$new(
    max_history = max_history,
    system_prompt = NULL  # Don't auto-add, we'll add from file
  )

  # Add messages
  for (i in seq_len(nrow(messages))) {
    conv$add_message(messages$role[i], messages$content[i])
  }

  message(sprintf("Conversation loaded from: %s", file_path))
  return(conv)
}
