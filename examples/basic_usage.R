# Basic Usage Examples for Chatbot Package
# ========================================

library(chatbot)

# Example 1: Simple OpenAI Chatbot
# ---------------------------------
# Set your API key (or use environment variable OPENAI_API_KEY)
# bot <- create_chatbot("openai", api_key = "your-api-key-here")

# Or if you have OPENAI_API_KEY set in environment:
bot <- create_chatbot("openai")

# Have a conversation
response <- bot$chat("Hello! Can you help me with R programming?")
print(response)

response <- bot$chat("What's the difference between a list and a vector?")
print(response)

# View conversation history
bot$history()


# Example 2: Claude Chatbot with System Prompt
# ---------------------------------------------
claude_bot <- create_chatbot(
  "claude",
  system_prompt = "You are an expert R programmer who provides concise, practical advice."
)

response <- claude_bot$chat("How do I read a CSV file in R?")
print(response)


# Example 3: Using the ask() method (no history)
# -----------------------------------------------
# Sometimes you want to ask a question without adding it to conversation history
quick_response <- bot$ask("What's 2 + 2?")
print(quick_response)

# This question won't appear in the conversation history
print(bot$conversation$summary())


# Example 4: Managing Conversation
# ---------------------------------
# Reset conversation
bot$reset()

# Check if conversation is clear
print(bot$conversation$summary())


# Example 5: Direct Class Usage
# ------------------------------
openai_bot <- OpenAIChatbot$new(
  model = "gpt-4",
  system_prompt = "You are a data science expert.",
  max_history = 50
)

response <- openai_bot$chat("Explain linear regression simply.")
print(response)


# Example 6: Saving and Loading Conversations
# --------------------------------------------
# Save conversation to file
save_conversation(bot$conversation, "my_conversation.json")

# Load conversation later
loaded_conv <- load_conversation("my_conversation.json")
print(loaded_conv$summary())

# You can attach it to a new bot if needed
# new_bot <- create_chatbot("openai")
# new_bot$conversation <- loaded_conv


# Example 7: Formatting Conversation for Display
# -----------------------------------------------
formatted <- format_conversation(bot$conversation)
cat(formatted)


# Example 8: Using Different Models
# ----------------------------------
# OpenAI GPT-4
gpt4_bot <- create_chatbot("openai", model = "gpt-4")

# Claude Opus (more capable model)
claude_opus <- create_chatbot("claude", model = "claude-3-opus-20240229")

# Claude Haiku (faster, cheaper model)
claude_haiku <- create_chatbot("claude", model = "claude-3-haiku-20240307")


# Example 9: Custom Temperature and Max Tokens
# ---------------------------------------------
# Lower temperature = more focused/deterministic
# Higher temperature = more creative/random
creative_response <- bot$chat(
  "Write a creative story about a robot.",
  temperature = 1.5,
  max_tokens = 500
)
print(creative_response)

focused_response <- bot$chat(
  "What is 15 * 24?",
  temperature = 0.1
)
print(focused_response)


# Example 10: Token Counting Utilities
# -------------------------------------
text <- "This is a sample text for token counting."
token_count <- count_tokens(text)
print(sprintf("Estimated tokens: %d", token_count))

# Truncate text to fit token limit
long_text <- paste(rep("This is a sentence. ", 100), collapse = "")
truncated <- truncate_text(long_text, max_tokens = 50)
print(truncated)
