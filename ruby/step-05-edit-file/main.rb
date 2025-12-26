# frozen_string_literal: true

# Step 5: The Complete Agent - Adding edit_file
#
# MILESTONE: Give Claude the ability to CREATE and MODIFY files.
# This is the final piece - your agent can now change the world!
#
# Key concepts:
# - With read + list + edit, Claude can understand AND modify codebases
# - The edit_file tool uses search/replace for precise edits
# - Creating new files: old_str="" means "create this file with new_str"
# - This is a fully functional coding agent in ~200 lines of code!
#
# You now have an agent that can:
# - Explore a codebase (list_files)
# - Understand files (read_file)
# - Make changes (edit_file)
# - And iterate based on results!
#
# =============================================================================
# MESSAGE FLOW SUMMARY
# =============================================================================
#
# Here's how messages flow in a complete agent interaction:
#
#   1. USER sends:      {role: "user", content: "Fix the bug"}
#   2. CLAUDE responds: {role: "assistant", content: [{type: "tool_use", name: "list_files", ...}]}
#   3. AGENT sends:     {role: "user", content: [{type: "tool_result", content: "[file1, file2]"}]}
#   4. CLAUDE responds: {role: "assistant", content: [{type: "tool_use", name: "read_file", ...}]}
#   5. AGENT sends:     {role: "user", content: [{type: "tool_result", content: "...code..."}]}
#   6. CLAUDE responds: {role: "assistant", content: [{type: "tool_use", name: "edit_file", ...}]}
#   7. AGENT sends:     {role: "user", content: [{type: "tool_result", content: "OK"}]}
#   8. CLAUDE responds: {role: "assistant", content: [{type: "text", text: "I fixed the bug!"}]}
#
# Notice: Claude can make MULTIPLE tool calls before giving a final text response.
# The agent loop keeps running until Claude responds with just text (no tool_use).

require "anthropic"
require "json"
require "fileutils"

# =============================================================================
# TOOL DEFINITIONS
# =============================================================================

# The complete toolkit: read, list, and edit files
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
  },
  {
    # NEW: edit_file tool - the key to a coding agent!
    # The search/replace approach (old_str -> new_str) is simple but powerful:
    # - Precise: only changes exactly what's specified
    # - Verifiable: Claude must know what's there to replace it
    # - Create files: old_str="" means create new file with new_str content
    name: "edit_file",
    description: <<~DESC,
      Make edits to a text file.

      Replaces 'old_str' with 'new_str' in the given file. 'old_str' and 'new_str' MUST be different from each other.

      If the file specified with path doesn't exist, it will be created.
    DESC
    input_schema: {
      type: "object",
      properties: {
        path: {
          type: "string",
          description: "The path to the file"
        },
        old_str: {
          type: "string",
          description: "Text to search for - must match exactly and must only have one match exactly"
        },
        new_str: {
          type: "string",
          description: "Text to replace old_str with"
        }
      },
      required: %w[path old_str new_str]
    }
  }
].freeze

# =============================================================================
# TOOL IMPLEMENTATIONS
# =============================================================================

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

# edit_file implements search/replace editing.
# This is a simple but effective approach used by many coding agents.
def edit_file(file_path, old_str, new_str)
  # Validate inputs
  raise "Invalid input parameters" if file_path.nil? || file_path.empty? || old_str == new_str

  if File.exist?(file_path)
    content = File.read(file_path)

    # Perform the replacement
    new_content = content.gsub(old_str, new_str)

    # Verify the replacement happened
    raise "old_str not found in file" if content == new_content && !old_str.empty?

    # Write the modified content
    File.write(file_path, new_content)
    "OK"
  elsif old_str.empty?
    # File doesn't exist - create it if old_str is empty (create mode)
    # Create parent directories if they don't exist
    dir = File.dirname(file_path)
    FileUtils.mkdir_p(dir) unless dir == "."

    File.write(file_path, new_str)
    "Successfully created file #{file_path}"
  else
    raise "File not found: #{file_path}"
  end
end

def execute_tool(name, input)
  case name
  when "read_file"
    begin
      content = File.read(input["path"])
      { result: content, is_error: false }
    rescue StandardError => e
      { result: e.message, is_error: true }
    end
  when "list_files"
    begin
      dir = input["path"] || "."
      files = walk_directory(dir)
      { result: files.to_json, is_error: false }
    rescue StandardError => e
      { result: e.message, is_error: true }
    end
  when "edit_file"
    begin
      result = edit_file(input["path"], input["old_str"], input["new_str"])
      { result: result, is_error: false }
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

# The Agent class is unchanged from step 3.
# The same loop handles any number of tools!

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
        case block.type
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
