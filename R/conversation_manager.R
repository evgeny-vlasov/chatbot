#' ConversationManager Class
#'
#' @description
#' Manages conversation history and context for chatbot interactions.
#'
#' @export
ConversationManager <- R6::R6Class(
  "ConversationManager",
  public = list(
    #' @field messages List of ChatMessage objects
    messages = NULL,

    #' @field max_history Maximum number of messages to retain
    max_history = NULL,

    #' @field system_prompt Optional system prompt
    system_prompt = NULL,

    #' @description
    #' Create a new ConversationManager
    #' @param max_history Maximum messages to retain (default: 100)
    #' @param system_prompt Optional system prompt
    #' @return A new ConversationManager object
    initialize = function(max_history = 100, system_prompt = NULL) {
      self$messages <- list()
      self$max_history <- max_history
      self$system_prompt <- system_prompt

      if (!is.null(system_prompt)) {
        self$add_message("system", system_prompt)
      }
    },

    #' @description
    #' Add a message to the conversation
    #' @param role Message role (user, assistant, system)
    #' @param content Message content
    #' @param metadata Optional metadata list
    add_message = function(role, content, metadata = list()) {
      message <- ChatMessage$new(role, content, metadata)
      self$messages <- append(self$messages, list(message))

      # Trim history if needed (keep system prompt)
      if (length(self$messages) > self$max_history) {
        system_msgs <- Filter(function(m) m$role == "system", self$messages)
        other_msgs <- Filter(function(m) m$role != "system", self$messages)

        # Keep most recent messages
        keep_count <- self$max_history - length(system_msgs)
        if (length(other_msgs) > keep_count) {
          other_msgs <- tail(other_msgs, keep_count)
        }

        self$messages <- c(system_msgs, other_msgs)
      }
    },

    #' @description
    #' Get all messages as a list
    #' @return List of message lists
    get_messages = function() {
      lapply(self$messages, function(m) m$to_list())
    },

    #' @description
    #' Get messages formatted for API calls
    #' @return List of formatted messages
    get_api_messages = function() {
      lapply(self$messages, function(m) {
        list(role = m$role, content = m$content)
      })
    },

    #' @description
    #' Clear all messages except system prompt
    clear = function() {
      if (!is.null(self$system_prompt)) {
        self$messages <- list(ChatMessage$new("system", self$system_prompt))
      } else {
        self$messages <- list()
      }
    },

    #' @description
    #' Get conversation summary
    #' @return Character string with summary
    summary = function() {
      n_messages <- length(self$messages)
      roles <- sapply(self$messages, function(m) m$role)

      sprintf(
        "Conversation: %d messages (%d user, %d assistant, %d system)",
        n_messages,
        sum(roles == "user"),
        sum(roles == "assistant"),
        sum(roles == "system")
      )
    },

    #' @description
    #' Print conversation
    print = function() {
      cat(self$summary(), "\n\n")
      for (msg in self$messages) {
        msg$print()
      }
    }
  )
)
