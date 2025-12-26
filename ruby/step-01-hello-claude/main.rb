# frozen_string_literal: true

# Step 1: Hello Claude - Your First API Call
#
# MILESTONE: Make a single API call to Claude and get a response.
# This is the foundation - proving you can communicate with the LLM.
#
# Key concepts:
# - Creating an Anthropic client (uses ANTHROPIC_API_KEY env var)
# - Structuring a message request
# - Handling the response

require "anthropic"

# Create a new Anthropic client.
# The SDK automatically reads the ANTHROPIC_API_KEY environment variable.
client = Anthropic::Client.new

# Make a single API call to Claude.
# This is the simplest possible interaction - one question, one answer.
message = client.messages.create(
  # Model specifies which Claude model to use
  model: "claude-opus-4-5-20251101",

  # max_tokens limits the response length (required parameter)
  max_tokens: 1024,

  # messages is the conversation history - here just one user message
  messages: [
    {
      role: "user",
      content: "What is a quaternion?"
    }
  ]
)

# Print Claude's response.
# message.content is an array of content blocks (usually just one text block)
message.content.each do |block|
  puts block.text if block.type == "text"
end
