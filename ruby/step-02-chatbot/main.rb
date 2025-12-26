# frozen_string_literal: true

# Step 2: Interactive Chatbot - The Conversation Loop
#
# MILESTONE: Build an interactive chat that maintains conversation history.
# This introduces the core "agentic loop" pattern - though without tools yet.
#
# Key concepts:
# - The agent loop: read input -> call LLM -> display output -> repeat
# - Conversation history: appending messages to maintain context
# - Separating concerns: Agent class encapsulates the chat logic
#
# =============================================================================
# MESSAGE TYPES IN THE ANTHROPIC API
# =============================================================================
#
# The API uses a conversation model with two roles:
#
#   ROLE: "user"      - Messages from the human (or tool results, as we'll see in step 3)
#   ROLE: "assistant" - Messages from Claude
#
# Each message contains CONTENT. In this step, we only see:
#
#   TYPE: "text"      - Plain text content (user input or Claude's response)
#
# The conversation array alternates: user, assistant, user, assistant...
# Claude is STATELESS - we must send the full conversation history each time.

require "anthropic"

# Agent class holds the state needed for a chat session.
class Agent
  def initialize(client)
    @client = client
    # Conversation history - this is what gives Claude "memory" of the chat.
    # Each message (user and assistant) gets appended here.
    #
    # Example conversation array after a few turns:
    #   [0] {role: "user",      content: "Hi!"}
    #   [1] {role: "assistant", content: [{type: "text", text: "Hello!"}]}
    #   [2] {role: "user",      content: "How are you?"}
    #   [3] {role: "assistant", content: [{type: "text", text: "I'm doing well!"}]}
    @conversation = []
  end

  # run_inference sends the conversation to Claude and returns the response.
  def run_inference
    @client.messages.create(
      model: "claude-opus-4-5-20251101",
      max_tokens: 1024,
      # Pass the entire conversation history - this is how Claude maintains context
      messages: @conversation
    )
  end

  # run starts the main conversation loop.
  # This is the heart of any agent: a loop that processes input and generates responses.
  def run
    $stdout.sync = true
    puts "Chat with Claude (use 'ctrl-c' to quit)"

    # THE AGENT LOOP: This pattern is fundamental to all agents.
    # 1. Get user input
    # 2. Add to conversation history
    # 3. Call the LLM
    # 4. Add response to history
    # 5. Display response
    # 6. Repeat
    loop do
      # Step 1: Get user input
      print "\e[94mYou\e[0m: "
      user_input = gets&.chomp
      break if user_input.nil?

      # Step 2: Add user message to conversation history
      # Creates: {role: "user", content: user_input}
      @conversation << { role: "user", content: user_input }

      # Step 3: Call the LLM with full conversation history
      message = run_inference

      # Step 4: Add Claude's response to conversation history
      # This is crucial - Claude needs to see its own previous responses
      # Creates: {role: "assistant", content: [...]}
      @conversation << { role: "assistant", content: message.content.map(&:to_h) }

      # Step 5: Display the response
      message.content.each do |block|
        puts "\e[93mClaude\e[0m: #{block.text}" if block.type.to_s == "text"
      end
      # Step 6: Loop continues...
    end
  end
end

# Create and run the agent
client = Anthropic::Client.new
agent = Agent.new(client)
agent.run
