#' Chatbot Base Class
#'
#' @description
#' Base class for chatbot implementations. Provides common interface and
#' conversation management functionality.
#'
#' @export
Chatbot <- R6::R6Class(
  "Chatbot",
  public = list(
    #' @field conversation ConversationManager object
    conversation = NULL,

    #' @field config List of configuration parameters
    config = NULL,

    #' @field api_key API key for the service
    api_key = NULL,

    #' @description
    #' Create a new Chatbot
    #' @param api_key API key for authentication
    #' @param system_prompt Optional system prompt
    #' @param max_history Maximum conversation history (default: 100)
    #' @param config Additional configuration list
    #' @return A new Chatbot object
    initialize = function(api_key = NULL, system_prompt = NULL, max_history = 100, config = list()) {
      self$api_key <- api_key %||% Sys.getenv("CHATBOT_API_KEY")
      self$config <- config
      self$conversation <- ConversationManager$new(
        max_history = max_history,
        system_prompt = system_prompt
      )
    },

    #' @description
    #' Send a message and get response (to be implemented by subclasses)
    #' @param message User message
    #' @param ... Additional parameters
    #' @return Assistant response
    chat = function(message, ...) {
      stop("chat() method must be implemented by subclass")
    },

    #' @description
    #' Send a message without adding to conversation history
    #' @param message User message
    #' @param ... Additional parameters
    #' @return Assistant response
    ask = function(message, ...) {
      stop("ask() method must be implemented by subclass")
    },

    #' @description
    #' Reset the conversation
    reset = function() {
      self$conversation$clear()
      invisible(self)
    },

    #' @description
    #' Get conversation history
    #' @return List of messages
    history = function() {
      self$conversation$get_messages()
    },

    #' @description
    #' Print chatbot information
    print = function() {
      cat(sprintf("Chatbot (%s)\n", class(self)[1]))
      cat(self$conversation$summary(), "\n")
    }
  )
)


#' Null coalescing operator
#' @keywords internal
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
