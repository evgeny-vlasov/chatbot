# Chatbot: A Flexible Chatbot Framework for R

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A modular and extensible chatbot framework for R that supports multiple conversation backends including OpenAI (GPT), Claude (Anthropic), and custom implementations. Provides tools for managing conversations, context, and chatbot interactions with a clean, object-oriented interface.

## Features

- **Multiple Providers**: Support for OpenAI (GPT-3.5, GPT-4) and Anthropic (Claude) APIs
- **Conversation Management**: Automatic conversation history tracking with configurable limits
- **Flexible Interface**: Both stateful conversations and stateless queries
- **R6 Classes**: Clean object-oriented design using R6
- **Context Preservation**: Maintain conversation context across multiple interactions
- **Utility Functions**: Token counting, text truncation, conversation formatting
- **Persistence**: Save and load conversation history
- **Extensible**: Easy to add custom chatbot implementations

## Installation

```r
# Install from local source
install.packages("path/to/chatbot", repos = NULL, type = "source")

# Or using devtools (if hosted on GitHub)
# devtools::install_github("username/chatbot")
```

### Dependencies

The package requires:
- `R6` (>= 2.5.0)
- `httr` (>= 1.4.0)
- `jsonlite` (>= 1.7.0)

```r
install.packages(c("R6", "httr", "jsonlite"))
```

## Quick Start

### Basic Usage

```r
library(chatbot)

# Create a chatbot (uses OPENAI_API_KEY environment variable)
bot <- create_chatbot("openai")

# Have a conversation
response <- bot$chat("Hello! Can you help me with R programming?")
print(response)

response <- bot$chat("What's the difference between a list and a vector?")
print(response)

# View conversation history
bot$history()
```

### With API Key

```r
# Provide API key directly
bot <- create_chatbot("openai", api_key = "sk-...")

# Or set environment variable
Sys.setenv(OPENAI_API_KEY = "sk-...")
bot <- create_chatbot("openai")
```

### Using Claude

```r
# Create Claude chatbot
bot <- create_chatbot("claude", api_key = "sk-ant-...")

# Or use environment variable ANTHROPIC_API_KEY
Sys.setenv(ANTHROPIC_API_KEY = "sk-ant-...")
bot <- create_chatbot("claude")

response <- bot$chat("Explain closures in R")
```

### With System Prompt

```r
bot <- create_chatbot(
  "openai",
  system_prompt = "You are a helpful R programming expert who provides concise answers."
)

response <- bot$chat("How do I read a CSV file?")
```

## Core Components

### Chatbot Classes

#### Base Chatbot Class
All chatbot implementations inherit from the `Chatbot` base class:

```r
bot <- OpenAIChatbot$new(
  api_key = "your-key",
  model = "gpt-4",
  system_prompt = "You are helpful.",
  max_history = 100
)
```

#### OpenAI Chatbot
```r
openai_bot <- OpenAIChatbot$new(
  model = "gpt-4",  # or "gpt-3.5-turbo"
  system_prompt = "You are an expert programmer."
)

response <- openai_bot$chat(
  "Write a function to sort a list",
  temperature = 0.7,
  max_tokens = 500
)
```

#### Claude Chatbot
```r
claude_bot <- ClaudeChatbot$new(
  model = "claude-3-opus-20240229",  # or sonnet, haiku
  system_prompt = "You are a helpful assistant."
)

response <- claude_bot$chat(
  "Explain recursion",
  temperature = 0.7,
  max_tokens = 1024
)
```

### Factory Function

The `create_chatbot()` function provides a simplified interface:

```r
bot <- create_chatbot(
  provider = "openai",  # or "claude"
  api_key = NULL,       # uses environment variable if NULL
  model = NULL,         # uses default if NULL
  system_prompt = NULL,
  max_history = 100,
  config = list()
)
```

### Conversation Manager

Manages conversation history and context:

```r
conv <- ConversationManager$new(
  max_history = 100,
  system_prompt = "You are helpful."
)

conv$add_message("user", "Hello")
conv$add_message("assistant", "Hi there!")

# Get messages
messages <- conv$get_messages()
api_messages <- conv$get_api_messages()

# Clear history (preserves system prompt)
conv$clear()

# Summary
print(conv$summary())
```

### Chat Messages

Individual message representation:

```r
msg <- ChatMessage$new(
  role = "user",  # "user", "assistant", or "system"
  content = "Hello, world!",
  metadata = list(source = "api")
)

# Convert to list
msg_list <- msg$to_list()
```

## Advanced Features

### Stateful vs Stateless

```r
# Stateful: adds to conversation history
response <- bot$chat("What is R?")
response <- bot$chat("Tell me more")  # Has context from previous

# Stateless: doesn't add to history
response <- bot$ask("What is R?")  # One-off question
```

### Managing History

```r
# Create with limited history
bot <- create_chatbot("openai", max_history = 20)

# View history
history <- bot$history()

# Reset conversation
bot$reset()
```

### Saving and Loading

```r
# Save conversation
save_conversation(bot$conversation, "my_chat.json")

# Load conversation
conv <- load_conversation("my_chat.json")

# Attach to new bot
new_bot <- create_chatbot("openai")
new_bot$conversation <- conv
```

### Formatting Output

```r
# Format conversation for display
formatted <- format_conversation(
  bot$conversation,
  include_system = FALSE
)
cat(formatted)
```

### Token Management

```r
# Estimate token count
text <- "This is a sample text."
tokens <- count_tokens(text)

# Truncate to token limit
long_text <- "..."
truncated <- truncate_text(long_text, max_tokens = 100)
```

## Examples

### Code Review Assistant

```r
reviewer <- create_chatbot(
  "openai",
  system_prompt = paste(
    "You are an expert R code reviewer.",
    "Analyze code for correctness, performance, style, and best practices.",
    "Provide constructive feedback with examples."
  )
)

code <- '
my_function <- function(x) {
  result <- c()
  for (i in 1:length(x)) {
    result <- c(result, x[i] * 2)
  }
  return(result)
}
'

review <- reviewer$chat(sprintf("Review this code:\n\n%s", code))
cat(review)
```

### Batch Processing

```r
questions <- c(
  "What is the tidyverse?",
  "How do I install packages?",
  "What is the pipe operator?"
)

bot <- create_chatbot("openai")

answers <- lapply(questions, function(q) {
  list(question = q, answer = bot$ask(q))
})
```

### Multi-turn Context

```r
bot <- create_chatbot("claude", system_prompt = "You are a patient R teacher.")

bot$chat("I'm new to R. What is a data frame?")
bot$chat("How is it different from a matrix?")
bot$chat("Can you show me an example?")
bot$chat("How do I add a new column?")

# Bot maintains context throughout
```

### Comparing Models

```r
compare_responses <- function(question) {
  gpt35 <- create_chatbot("openai", model = "gpt-3.5-turbo")
  gpt4 <- create_chatbot("openai", model = "gpt-4")

  cat("GPT-3.5:", gpt35$ask(question), "\n\n")
  cat("GPT-4:", gpt4$ask(question), "\n")
}

compare_responses("Explain closures in R")
```

## API Reference

### Methods

#### `chat(message, ...)`
Send a message and add it to conversation history.
- **Parameters**:
  - `message`: User message (character)
  - `temperature`: Sampling temperature (numeric)
  - `max_tokens`: Maximum response tokens (integer)
- **Returns**: Assistant response (character)

#### `ask(message, ...)`
Send a message without adding to history.
- **Parameters**: Same as `chat()`
- **Returns**: Assistant response (character)

#### `reset()`
Clear conversation history (preserves system prompt).

#### `history()`
Get conversation history as a list of messages.

## Configuration

### Environment Variables

```bash
# OpenAI
export OPENAI_API_KEY="sk-..."

# Anthropic (Claude)
export ANTHROPIC_API_KEY="sk-ant-..."

# Generic (if using base Chatbot)
export CHATBOT_API_KEY="..."
```

### Models

**OpenAI Models:**
- `gpt-3.5-turbo` (default, fast and cost-effective)
- `gpt-4` (more capable, slower, more expensive)
- `gpt-4-turbo`

**Claude Models:**
- `claude-3-sonnet-20240229` (default, balanced)
- `claude-3-opus-20240229` (most capable)
- `claude-3-haiku-20240307` (fastest, most cost-effective)

## Testing

```r
# Run tests
library(testthat)
test_dir("tests/")

# Or specific test file
test_file("tests/test_message.R")
```

## Project Structure

```
chatbot/
├── DESCRIPTION          # Package metadata
├── NAMESPACE           # Exported functions
├── LICENSE             # MIT license
├── README.md          # This file
├── R/                 # Source code
│   ├── message.R
│   ├── conversation_manager.R
│   ├── chatbot_base.R
│   ├── chatbot_openai.R
│   ├── chatbot_claude.R
│   ├── factory.R
│   └── utils.R
├── tests/             # Unit tests
│   ├── test_message.R
│   ├── test_conversation.R
│   └── test_utils.R
└── examples/          # Example scripts
    ├── basic_usage.R
    └── advanced_usage.R
```

## Extending the Package

Create custom chatbot implementations by inheriting from `Chatbot`:

```r
CustomChatbot <- R6::R6Class(
  "CustomChatbot",
  inherit = Chatbot,
  public = list(
    initialize = function(...) {
      super$initialize(...)
    },

    chat = function(message, ...) {
      # Your implementation
      self$conversation$add_message("user", message)
      response <- private$your_api_call(...)
      self$conversation$add_message("assistant", response)
      return(response)
    },

    ask = function(message, ...) {
      # Your stateless implementation
    }
  ),
  private = list(
    your_api_call = function(...) {
      # Custom API integration
    }
  )
)
```

## Best Practices

1. **Use Environment Variables**: Store API keys in environment variables, not in code
2. **Manage History**: Set appropriate `max_history` to control token usage and costs
3. **Error Handling**: Wrap API calls in `tryCatch()` for production use
4. **Rate Limiting**: Add delays between API calls to respect rate limits
5. **Cost Awareness**: Monitor token usage, especially with GPT-4 and Claude Opus
6. **System Prompts**: Use clear system prompts to guide chatbot behavior
7. **Testing**: Use mock chatbots for testing without API calls

## Troubleshooting

### API Key Issues
```r
# Check if API key is set
Sys.getenv("OPENAI_API_KEY")

# Set temporarily
Sys.setenv(OPENAI_API_KEY = "sk-...")
```

### Rate Limiting
```r
# Add delays between requests
for (q in questions) {
  response <- bot$ask(q)
  Sys.sleep(1)  # Wait 1 second
}
```

### Connection Errors
- Check internet connection
- Verify API key is valid
- Check API service status

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [R6](https://r6.r-lib.org/) for object-oriented programming
- Uses [httr](https://httr.r-lib.org/) for HTTP requests
- Uses [jsonlite](https://cran.r-project.org/package=jsonlite) for JSON parsing

## Citation

```r
citation("chatbot")
```

## Contact

For questions, issues, or feature requests, please open an issue on GitHub.

---

**Note**: This package requires valid API keys for OpenAI and/or Anthropic services. Usage of these APIs may incur costs according to each provider's pricing.
