# frozen_string_literal: true

# Step 3: Adding Tools - The read_file Tool
#
# MILESTONE: Give Claude the ability to read files from the filesystem.
# This is where the chatbot becomes an AGENT - it can now take actions!
#
# Key concepts:
# - Tool definitions: telling Claude what tools exist and how to use them
# - Tool execution: actually running the tool when Claude requests it
# - The tool loop: Claude may need multiple tool calls before responding
# - JSON Schema: how tools describe their parameters to Claude
#
# What makes this an "agent"?
# An agent is an LLM that can take actions in the world. By giving Claude
# the read_file tool, it can now access information outside its context window.
#
# =============================================================================
# MESSAGE TYPES - NOW WITH TOOLS!
# =============================================================================
#
# Messages still have two roles, but now have MORE CONTENT BLOCK TYPES:
#
#   ROLE: "user"      - Human messages OR tool results (yes, tool results!)
#   ROLE: "assistant" - Claude's responses (may include tool requests)
#
# Content block types:
#
#   TYPE: "text"        - Plain text (input or response)
#   TYPE: "tool_use"    - Claude requesting to use a tool (assistant only)
#                         Contains: id, name, input (the tool's parameters)
#   TYPE: "tool_result" - Result of executing a tool (sent in user message!)
#                         Contains: tool_use_id, content, is_error
#
# Example conversation with tool use:
#
#   [0] {role: "user",      content: "Read config.json"}
#   [1] {role: "assistant", content: [{type: "tool_use", id: "xyz", name: "read_file", input: {path: "config.json"}}]}
#   [2] {role: "user",      content: [{type: "tool_result", tool_use_id: "xyz", content: "{...file contents...}"}]}
#   [3] {role: "assistant", content: [{type: "text", text: "The config file contains..."}]}
#
# KEY INSIGHT: Tool results are sent as "user" messages! This is the API convention.

require "anthropic"
require "json"

# =============================================================================
# TOOL DEFINITIONS
# =============================================================================

# Tool definitions describe tools that Claude can use.
# Each includes everything Claude needs to know to use the tool correctly:
# - name: how Claude refers to the tool
# - description: when and why to use it (this is very important!)
# - input_schema: what parameters the tool accepts (JSON Schema format)

TOOLS = [
  {
    name: "read_file",
    description: "Read the contents of a given relative file path. Use this when you want to see what's inside a file. Do not use this with directory names.",
    input_schema: {
      type: "object",
      properties: {
        path: {
          type: "string",
          description: "The relative path of a file in the working directory."
        }
      },
      required: ["path"]
    }
  }
].freeze

# =============================================================================
# TOOL IMPLEMENTATIONS
# =============================================================================

# execute_tool finds and runs the requested tool, returning the result.
# This is the bridge between Claude's request and actual code execution.
#
# Parameters come from the tool_use content block:
#   - name: which tool to execute
#   - input: parameters for the tool
#
# Returns: { result: string, is_error: boolean }
def execute_tool(name, input)
  case name
  when "read_file"
    begin
      content = File.read(input["path"])
      { result: content, is_error: false }
    rescue StandardError => e
      { result: e.message, is_error: true }
    end
  else
    { result: "Tool not found", is_error: true }
  end
end

# =============================================================================
# AGENT
# =============================================================================

class Agent
  def initialize(client)
    @client = client
    @conversation = []
  end

  def run_inference
    @client.messages.create(
      model: "claude-opus-4-5-20251101",
      max_tokens: 1024,
      messages: @conversation,
      tools: TOOLS # NEW: Tell Claude about available tools
    )
  end

  def run
    $stdout.sync = true
    puts "Chat with Claude (use 'ctrl-c' to quit)"

    # NEW: read_user_input flag controls whether we wait for user input.
    # When Claude uses a tool, we need to send the result back without
    # waiting for the user - this enables multi-step tool use.
    read_user_input = true

    loop do
      if read_user_input
        print "\e[94mYou\e[0m: "
        user_input = gets&.chomp
        break if user_input.nil?

        @conversation << { role: "user", content: user_input }
      end

      message = run_inference

      # Add Claude's response to conversation history
      @conversation << { role: "assistant", content: message.content.map(&:to_h) }

      # Process Claude's response content blocks.
      # An assistant message can contain MULTIPLE content blocks of different types!
      # For example: [{type: "text", ...}, {type: "tool_use", ...}]
      tool_results = []

      message.content.each do |block|
        case block.type.to_s
        when "text"
          # Content block type: "text" - regular text response
          puts "\e[93mClaude\e[0m: #{block.text}"
        when "tool_use"
          # Content block type: "tool_use" - Claude wants to call a tool!
          # Contains: block.id (unique ID), block.name, block.input
          # We execute the tool and create a "tool_result" block
          puts "\e[92mtool\e[0m: #{block.name}(#{block.input.to_json})"
          result = execute_tool(block.name, block.input)
          tool_results << {
            type: "tool_result",
            tool_use_id: block.id,
            content: result[:result],
            is_error: result[:is_error]
          }
        end
      end

      # If there were tool calls, send results back to Claude.
      # Don't wait for user input - let Claude process the results first.
      if tool_results.empty?
        read_user_input = true
        next
      end

      read_user_input = false

      # IMPORTANT: Tool results are sent as a "user" message!
      # This creates: {role: "user", content: [{type: "tool_result", tool_use_id: "...", content: "..."}]}
      # Why "user"? The API treats tool results as if the user is providing them.
      # The tool_use_id links each result back to Claude's original tool_use request.
      @conversation << { role: "user", content: tool_results }
    end
  end
end

client = Anthropic::Client.new
agent = Agent.new(client)
agent.run
