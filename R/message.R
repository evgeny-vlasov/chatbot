#' ChatMessage Class
#'
#' @description
#' R6 class representing a chat message with role and content.
#'
#' @export
ChatMessage <- R6::R6Class(
  "ChatMessage",
  public = list(
    #' @field role Character string indicating message role (user, assistant, system)
    role = NULL,

    #' @field content Character string with message content
    content = NULL,

    #' @field timestamp POSIXct timestamp of message creation
    timestamp = NULL,

    #' @field metadata List of additional metadata
    metadata = NULL,

    #' @description
    #' Create a new ChatMessage object
    #' @param role Character string for message role
    #' @param content Character string for message content
    #' @param metadata Optional list of additional metadata
    #' @return A new ChatMessage object
    initialize = function(role, content, metadata = list()) {
      if (!role %in% c("user", "assistant", "system")) {
        stop("Role must be one of: user, assistant, system")
      }

      self$role <- role
      self$content <- content
      self$timestamp <- Sys.time()
      self$metadata <- metadata
    },

    #' @description
    #' Convert message to list format
    #' @return List representation of the message
    to_list = function() {
      list(
        role = self$role,
        content = self$content,
        timestamp = self$timestamp,
        metadata = self$metadata
      )
    },

    #' @description
    #' Print method for ChatMessage
    print = function() {
      cat(sprintf("[%s] %s: %s\n",
                  format(self$timestamp, "%Y-%m-%d %H:%M:%S"),
                  self$role,
                  self$content))
    }
  )
)
