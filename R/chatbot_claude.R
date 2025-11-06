#' Claude Chatbot Class
#'
#' @description
#' Chatbot implementation using Anthropic's Claude API.
#'
#' @export
ClaudeChatbot <- R6::R6Class(
  "ClaudeChatbot",
  inherit = Chatbot,
  public = list(
    #' @field model Model name (default: claude-3-sonnet-20240229)
    model = NULL,

    #' @field endpoint API endpoint
    endpoint = NULL,

    #' @field api_version API version
    api_version = NULL,

    #' @description
    #' Create a new Claude Chatbot
    #' @param api_key Anthropic API key
    #' @param model Model name (default: claude-3-sonnet-20240229)
    #' @param system_prompt Optional system prompt
    #' @param max_history Maximum conversation history
    #' @param config Additional configuration
    #' @return A new ClaudeChatbot object
    initialize = function(api_key = NULL,
                         model = "claude-3-sonnet-20240229",
                         system_prompt = NULL,
                         max_history = 100,
                         config = list()) {
      super$initialize(
        api_key = api_key %||% Sys.getenv("ANTHROPIC_API_KEY"),
        system_prompt = system_prompt,
        max_history = max_history,
        config = config
      )

      self$model <- model
      self$endpoint <- "https://api.anthropic.com/v1/messages"
      self$api_version <- "2023-06-01"
    },

    #' @description
    #' Send a message and get response
    #' @param message User message
    #' @param temperature Sampling temperature (0-1, default: 0.7)
    #' @param max_tokens Maximum tokens in response (default: 1024)
    #' @param ... Additional API parameters
    #' @return Assistant response as character string
    chat = function(message, temperature = 0.7, max_tokens = 1024, ...) {
      # Add user message to conversation
      self$conversation$add_message("user", message)

      # Get response
      response <- private$call_api(
        temperature = temperature,
        max_tokens = max_tokens,
        ...
      )

      # Add assistant response to conversation
      self$conversation$add_message("assistant", response)

      return(response)
    },

    #' @description
    #' Ask a question without adding to conversation history
    #' @param message User message
    #' @param temperature Sampling temperature (default: 0.7)
    #' @param max_tokens Maximum tokens in response (default: 1024)
    #' @param ... Additional API parameters
    #' @return Assistant response as character string
    ask = function(message, temperature = 0.7, max_tokens = 1024, ...) {
      # Create temporary messages
      temp_messages <- private$format_messages_for_api()
      temp_messages <- append(temp_messages, list(list(role = "user", content = message)))

      # Get response without updating conversation
      response <- private$call_api(
        messages = temp_messages,
        temperature = temperature,
        max_tokens = max_tokens,
        ...
      )

      return(response)
    }
  ),

  private = list(
    #' @description
    #' Format messages for Claude API (exclude system messages)
    #' @return List of formatted messages
    format_messages_for_api = function() {
      messages <- self$conversation$get_api_messages()
      # Claude API expects system as a separate parameter, not in messages
      Filter(function(m) m$role != "system", messages)
    },

    #' @description
    #' Make API call to Claude
    #' @param messages Optional custom messages
    #' @param temperature Sampling temperature
    #' @param max_tokens Maximum tokens
    #' @param ... Additional parameters
    #' @return Response text
    call_api = function(messages = NULL, temperature = 0.7, max_tokens = 1024, ...) {
      if (is.null(self$api_key) || self$api_key == "") {
        stop("Anthropic API key not set. Set ANTHROPIC_API_KEY environment variable or pass api_key.")
      }

      messages <- messages %||% private$format_messages_for_api()

      # Build request body
      body <- list(
        model = self$model,
        messages = messages,
        max_tokens = max_tokens,
        temperature = temperature
      )

      # Add system prompt if present
      if (!is.null(self$conversation$system_prompt)) {
        body$system <- self$conversation$system_prompt
      }

      # Add any additional parameters
      extra_params <- list(...)
      body <- c(body, extra_params)

      # Make API request
      response <- httr::POST(
        self$endpoint,
        httr::add_headers(
          "x-api-key" = self$api_key,
          "anthropic-version" = self$api_version,
          "Content-Type" = "application/json"
        ),
        body = jsonlite::toJSON(body, auto_unbox = TRUE),
        encode = "raw"
      )

      # Check for errors
      if (httr::http_error(response)) {
        error_content <- httr::content(response, "text", encoding = "UTF-8")
        stop(sprintf("Claude API error: %s", error_content))
      }

      # Parse response
      result <- httr::content(response, "parsed")

      if (is.null(result$content) || length(result$content) == 0) {
        stop("No response from Claude API")
      }

      return(result$content[[1]]$text)
    }
  )
)
