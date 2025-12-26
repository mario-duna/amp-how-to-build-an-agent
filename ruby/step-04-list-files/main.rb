# frozen_string_literal: true

# Step 4: Multiple Tools - Adding list_files
#
# MILESTONE: Give Claude a second tool to explore the filesystem.
# This shows how easy it is to add more capabilities to your agent.
#
# Key concepts:
# - Adding tools is just adding to the tools array
# - Each tool follows the same pattern: definition + implementation
# - Claude can now explore directories to find files, then read them
#
# With read_file + list_files, Claude can navigate and understand codebases!

require "anthropic"
require "json"

# =============================================================================
# TOOL DEFINITIONS
# =============================================================================

# NEW: Two tools! Adding capabilities is as simple as adding to this array.
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
  },
  {
    # NEW: list_files tool - complements read_file for exploring codebases
    name: "list_files",
    description: "List files and directories at a given path. If no path is provided, lists files in the current directory.",
    input_schema: {
      type: "object",
      properties: {
        path: {
          type: "string",
          description: "Optional relative path to list files from. Defaults to current directory if not provided."
        }
      },
      required: []
    }
  }
].freeze

# =============================================================================
# TOOL IMPLEMENTATIONS
# =============================================================================

# Recursively walk a directory and return all file/folder paths
def walk_directory(dir)
  files = []
  Dir.glob("#{dir}/**/*", File::FNM_DOTMATCH).each do |path|
    next if path.end_with?("/.") || path.end_with?("/..")

    rel_path = path.sub("#{dir}/", "")
    files << if File.directory?(path)
               "#{rel_path}/"
             else
               rel_path
             end
  end
  files
end

def execute_tool(name, input)
  # Convert input to hash with string keys for consistent access
  input_hash = input.is_a?(Hash) ? input.transform_keys(&:to_s) : input.to_h.transform_keys(&:to_s)

  case name.to_s
  when "read_file"
    begin
      content = File.read(input_hash["path"])
      { result: content, is_error: false }
    rescue StandardError => e
      { result: e.message, is_error: true }
    end
  when "list_files"
    begin
      # Default to current directory if no path provided
      dir = input_hash["path"] || "."
      files = walk_directory(dir)
      # Return as JSON array - structured data is easier for Claude to work with
      { result: files.to_json, is_error: false }
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
      tools: TOOLS
    )
  end

  def run
    $stdout.sync = true
    puts "Chat with Claude (use 'ctrl-c' to quit)"

    read_user_input = true

    loop do
      if read_user_input
        print "\e[94mYou\e[0m: "
        user_input = gets&.chomp
        break if user_input.nil?

        @conversation << { role: "user", content: user_input }
      end

      message = run_inference

      @conversation << { role: "assistant", content: message.content.map(&:to_h) }

      tool_results = []

      message.content.each do |block|
        case block.type.to_s
        when "text"
          puts "\e[93mClaude\e[0m: #{block.text}"
        when "tool_use"
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

      if tool_results.empty?
        read_user_input = true
        next
      end

      read_user_input = false
      @conversation << { role: "user", content: tool_results }
    end
  end
end

client = Anthropic::Client.new
agent = Agent.new(client)
agent.run
