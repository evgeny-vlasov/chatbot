#' OpenAI Chatbot Class
#'
#' @description
#' Chatbot implementation using OpenAI's API (GPT models).
#'
#' @export
OpenAIChatbot <- R6::R6Class(
  "OpenAIChatbot",
  inherit = Chatbot,
  public = list(
    #' @field model Model name (default: gpt-3.5-turbo)
    model = NULL,

    #' @field endpoint API endpoint
    endpoint = NULL,

    #' @description
    #' Create a new OpenAI Chatbot
    #' @param api_key OpenAI API key
    #' @param model Model name (default: gpt-3.5-turbo)
    #' @param system_prompt Optional system prompt
    #' @param max_history Maximum conversation history
    #' @param config Additional configuration
    #' @return A new OpenAIChatbot object
    initialize = function(api_key = NULL,
                         model = "gpt-3.5-turbo",
                         system_prompt = NULL,
                         max_history = 100,
                         config = list()) {
      super$initialize(
        api_key = api_key %||% Sys.getenv("OPENAI_API_KEY"),
        system_prompt = system_prompt,
        max_history = max_history,
        config = config
      )

      self$model <- model
      self$endpoint <- "https://api.openai.com/v1/chat/completions"
    },

    #' @description
    #' Send a message and get response
    #' @param message User message
    #' @param temperature Sampling temperature (0-2, default: 0.7)
    #' @param max_tokens Maximum tokens in response
    #' @param ... Additional API parameters
    #' @return Assistant response as character string
    chat = function(message, temperature = 0.7, max_tokens = NULL, ...) {
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
    #' @param max_tokens Maximum tokens in response
    #' @param ... Additional API parameters
    #' @return Assistant response as character string
    ask = function(message, temperature = 0.7, max_tokens = NULL, ...) {
      # Create temporary messages
      temp_messages <- self$conversation$get_api_messages()
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
    #' Make API call to OpenAI
    #' @param messages Optional custom messages (otherwise uses conversation)
    #' @param temperature Sampling temperature
    #' @param max_tokens Maximum tokens
    #' @param ... Additional parameters
    #' @return Response text
    call_api = function(messages = NULL, temperature = 0.7, max_tokens = NULL, ...) {
      if (is.null(self$api_key) || self$api_key == "") {
        stop("OpenAI API key not set. Set OPENAI_API_KEY environment variable or pass api_key.")
      }

      messages <- messages %||% self$conversation$get_api_messages()

      # Build request body
      body <- list(
        model = self$model,
        messages = messages,
        temperature = temperature
      )

      if (!is.null(max_tokens)) {
        body$max_tokens <- max_tokens
      }

      # Add any additional parameters
      extra_params <- list(...)
      body <- c(body, extra_params)

      # Make API request
      response <- httr::POST(
        self$endpoint,
        httr::add_headers(
          "Authorization" = paste("Bearer", self$api_key),
          "Content-Type" = "application/json"
        ),
        body = jsonlite::toJSON(body, auto_unbox = TRUE),
        encode = "raw"
      )

      # Check for errors
      if (httr::http_error(response)) {
        error_content <- httr::content(response, "text", encoding = "UTF-8")
        stop(sprintf("OpenAI API error: %s", error_content))
      }

      # Parse response
      result <- httr::content(response, "parsed")

      if (is.null(result$choices) || length(result$choices) == 0) {
        stop("No response from OpenAI API")
      }

      return(result$choices[[1]]$message$content)
    }
  )
)
