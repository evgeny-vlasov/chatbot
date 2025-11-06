# Advanced Usage Examples for Chatbot Package
# ============================================

library(chatbot)

# Example 1: Multi-turn Conversation with Context
# ------------------------------------------------
bot <- create_chatbot(
  "openai",
  system_prompt = "You are a patient teacher helping someone learn R programming."
)

# Build up context through conversation
bot$chat("I'm new to R. Can you explain what a data frame is?")
bot$chat("How is it different from a matrix?")
bot$chat("Can you show me an example?")
bot$chat("How do I add a new column?")

# The bot maintains context throughout
print(format_conversation(bot$conversation))


# Example 2: Comparing Responses from Different Models
# -----------------------------------------------------
compare_responses <- function(question) {
  gpt35 <- create_chatbot("openai", model = "gpt-3.5-turbo")
  gpt4 <- create_chatbot("openai", model = "gpt-4")

  response_35 <- gpt35$ask(question)
  response_4 <- gpt4$ask(question)

  cat("=== GPT-3.5 Turbo ===\n")
  cat(response_35, "\n\n")

  cat("=== GPT-4 ===\n")
  cat(response_4, "\n")
}

compare_responses("Explain the concept of closures in R.")


# Example 3: Batch Processing Questions
# --------------------------------------
process_questions <- function(questions, bot) {
  results <- list()

  for (i in seq_along(questions)) {
    cat(sprintf("Processing question %d/%d...\n", i, length(questions)))

    response <- bot$ask(questions[i])
    results[[i]] <- list(
      question = questions[i],
      answer = response,
      tokens = count_tokens(paste(questions[i], response))
    )

    # Be nice to the API
    Sys.sleep(1)
  }

  return(results)
}

questions <- c(
  "What is the tidyverse?",
  "How do I install packages in R?",
  "What is the pipe operator?"
)

bot <- create_chatbot("openai")
results <- process_questions(questions, bot)

# Display results
for (result in results) {
  cat(sprintf("\nQ: %s\nA: %s\nTokens: ~%d\n",
              result$question,
              result$answer,
              result$tokens))
}


# Example 4: Error Handling and Retry Logic
# ------------------------------------------
safe_chat <- function(bot, message, max_retries = 3) {
  retries <- 0

  while (retries < max_retries) {
    result <- tryCatch(
      {
        bot$chat(message)
      },
      error = function(e) {
        message(sprintf("Error: %s", e$message))
        if (retries < max_retries - 1) {
          message(sprintf("Retrying... (%d/%d)", retries + 1, max_retries))
        }
        NULL
      }
    )

    if (!is.null(result)) {
      return(result)
    }

    retries <- retries + 1
    Sys.sleep(2^retries)  # Exponential backoff
  }

  stop("Failed after maximum retries")
}


# Example 5: Creating a Code Review Assistant
# --------------------------------------------
create_code_reviewer <- function(provider = "openai") {
  create_chatbot(
    provider,
    system_prompt = paste(
      "You are an expert R code reviewer.",
      "Analyze code for:",
      "1. Correctness and potential bugs",
      "2. Performance and efficiency",
      "3. Style and readability",
      "4. Best practices",
      "Provide constructive feedback with examples."
    )
  )
}

reviewer <- create_code_reviewer()

code_to_review <- '
my_function <- function(x) {
  result <- c()
  for (i in 1:length(x)) {
    result <- c(result, x[i] * 2)
  }
  return(result)
}
'

review <- reviewer$chat(sprintf("Please review this R code:\n\n%s", code_to_review))
cat(review)


# Example 6: Conversation Analytics
# ----------------------------------
analyze_conversation <- function(conversation) {
  messages <- conversation$get_messages()

  total_messages <- length(messages)
  user_messages <- sum(sapply(messages, function(m) m$role == "user"))
  assistant_messages <- sum(sapply(messages, function(m) m$role == "assistant"))

  total_tokens <- sum(sapply(messages, function(m) count_tokens(m$content)))

  avg_user_length <- mean(sapply(
    Filter(function(m) m$role == "user", messages),
    function(m) nchar(m$content)
  ))

  avg_assistant_length <- mean(sapply(
    Filter(function(m) m$role == "assistant", messages),
    function(m) nchar(m$content)
  ))

  list(
    total_messages = total_messages,
    user_messages = user_messages,
    assistant_messages = assistant_messages,
    total_tokens = total_tokens,
    avg_user_length = round(avg_user_length),
    avg_assistant_length = round(avg_assistant_length)
  )
}

# Usage
stats <- analyze_conversation(bot$conversation)
print(stats)


# Example 7: Custom Chatbot Subclass
# -----------------------------------
# You can extend the base Chatbot class for custom implementations

MockChatbot <- R6::R6Class(
  "MockChatbot",
  inherit = Chatbot,
  public = list(
    initialize = function(system_prompt = NULL, max_history = 100) {
      super$initialize(
        api_key = "mock",
        system_prompt = system_prompt,
        max_history = max_history
      )
    },

    chat = function(message, ...) {
      self$conversation$add_message("user", message)
      response <- sprintf("Mock response to: %s", message)
      self$conversation$add_message("assistant", response)
      return(response)
    },

    ask = function(message, ...) {
      sprintf("Mock response to: %s", message)
    }
  )
)

# Use the mock chatbot for testing
mock_bot <- MockChatbot$new()
mock_bot$chat("Hello!")


# Example 8: Conversation Branching
# ----------------------------------
# Save conversation state and explore different branches

bot <- create_chatbot("openai")
bot$chat("I want to learn about machine learning.")
bot$chat("Tell me about supervised learning.")

# Save this point
checkpoint <- bot$conversation$get_messages()

# Branch 1: Continue with classification
bot$chat("What are classification algorithms?")
response1 <- bot$chat("Tell me about decision trees.")

# Restore checkpoint and take different branch
bot$conversation$clear()
for (msg in checkpoint) {
  bot$conversation$add_message(msg$role, msg$content)
}

# Branch 2: Continue with regression
bot$chat("What are regression algorithms?")
response2 <- bot$chat("Tell me about linear regression.")


# Example 9: Conversation History Management
# -------------------------------------------
bot <- create_chatbot("openai", max_history = 5)

# Add many messages
for (i in 1:10) {
  bot$chat(sprintf("Message number %d", i))
}

# Only the most recent 5 exchanges are kept
print(bot$conversation$summary())


# Example 10: Multi-provider Workflow
# ------------------------------------
# Use different providers for different tasks

code_bot <- create_chatbot("openai", model = "gpt-4")
chat_bot <- create_chatbot("claude")

# Use GPT-4 for code generation
code <- code_bot$ask("Write a function to calculate the Fibonacci sequence in R.")

# Use Claude for explanation
explanation <- chat_bot$ask(
  sprintf("Explain how this R code works:\n\n%s", code)
)

cat("=== Generated Code ===\n")
cat(code, "\n\n")
cat("=== Explanation ===\n")
cat(explanation, "\n")
