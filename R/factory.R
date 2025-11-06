#' Create a Chatbot Instance
#'
#' @description
#' Factory function to create chatbot instances with simplified interface.
#'
#' @param provider Character string indicating provider ("openai" or "claude")
#' @param api_key API key for authentication
#' @param model Model name (provider-specific)
#' @param system_prompt Optional system prompt
#' @param max_history Maximum conversation history (default: 100)
#' @param config Additional configuration list
#'
#' @return A chatbot object (OpenAIChatbot or ClaudeChatbot)
#'
#' @examples
#' \dontrun{
#' # Create OpenAI chatbot
#' bot <- create_chatbot("openai", api_key = "sk-...")
#'
#' # Create Claude chatbot
#' bot <- create_chatbot("claude", api_key = "sk-ant-...")
#'
#' # With system prompt
#' bot <- create_chatbot(
#'   "openai",
#'   system_prompt = "You are a helpful coding assistant."
#' )
#' }
#'
#' @export
create_chatbot <- function(provider = c("openai", "claude"),
                          api_key = NULL,
                          model = NULL,
                          system_prompt = NULL,
                          max_history = 100,
                          config = list()) {

  provider <- match.arg(provider)

  switch(
    provider,
    "openai" = {
      OpenAIChatbot$new(
        api_key = api_key,
        model = model %||% "gpt-3.5-turbo",
        system_prompt = system_prompt,
        max_history = max_history,
        config = config
      )
    },
    "claude" = {
      ClaudeChatbot$new(
        api_key = api_key,
        model = model %||% "claude-3-sonnet-20240229",
        system_prompt = system_prompt,
        max_history = max_history,
        config = config
      )
    }
  )
}
