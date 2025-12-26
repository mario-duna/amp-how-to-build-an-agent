// Step 5: The Complete Agent - Adding edit_file
//
// MILESTONE: Give Claude the ability to CREATE and MODIFY files.
// This is the final piece - your agent can now change the world!
//
// Key concepts:
// - With read + list + edit, Claude can understand AND modify codebases
// - The edit_file tool uses search/replace for precise edits
// - Creating new files: old_str="" means "create this file with new_str"
// - This is a fully functional coding agent in ~200 lines of code!
//
// You now have an agent that can:
// - Explore a codebase (list_files)
// - Understand files (read_file)
// - Make changes (edit_file)
// - And iterate based on results!
//
// =============================================================================
// MESSAGE FLOW SUMMARY
// =============================================================================
//
// Here's how messages flow in a complete agent interaction:
//
//   1. USER sends:      {role: "user", content: "Fix the bug"}
//   2. CLAUDE responds: {role: "assistant", content: [{type: "tool_use", name: "list_files", ...}]}
//   3. AGENT sends:     {role: "user", content: [{type: "tool_result", content: "[file1, file2]"}]}
//   4. CLAUDE responds: {role: "assistant", content: [{type: "tool_use", name: "read_file", ...}]}
//   5. AGENT sends:     {role: "user", content: [{type: "tool_result", content: "...code..."}]}
//   6. CLAUDE responds: {role: "assistant", content: [{type: "tool_use", name: "edit_file", ...}]}
//   7. AGENT sends:     {role: "user", content: [{type: "tool_result", content: "OK"}]}
//   8. CLAUDE responds: {role: "assistant", content: [{type: "text", text: "I fixed the bug!"}]}
//
// Notice: Claude can make MULTIPLE tool calls before giving a final text response.
// The agent loop keeps running until Claude responds with just text (no tool_use).

import Anthropic from "@anthropic-ai/sdk";
import * as readline from "readline";
import * as fs from "fs/promises";
import * as path from "path";

const client = new Anthropic();

// =============================================================================
// TOOL DEFINITIONS
// =============================================================================

// The complete toolkit: read, list, and edit files
const tools = [
  {
    name: "read_file",
    description:
      "Read the contents of a given relative file path. Use this when you want to see what's inside a file. Do not use this with directory names.",
    input_schema: {
      type: "object",
      properties: {
        path: {
          type: "string",
          description:
            "The relative path of a file in the working directory.",
        },
      },
      required: ["path"],
    },
  },
  {
    name: "list_files",
    description:
      "List files and directories at a given path. If no path is provided, lists files in the current directory.",
    input_schema: {
      type: "object",
      properties: {
        path: {
          type: "string",
          description:
            "Optional relative path to list files from. Defaults to current directory if not provided.",
        },
      },
      required: [],
    },
  },
  {
    // NEW: edit_file tool - the key to a coding agent!
    // The search/replace approach (old_str -> new_str) is simple but powerful:
    // - Precise: only changes exactly what's specified
    // - Verifiable: Claude must know what's there to replace it
    // - Create files: old_str="" means create new file with new_str content
    name: "edit_file",
    description: `Make edits to a text file.

Replaces 'old_str' with 'new_str' in the given file. 'old_str' and 'new_str' MUST be different from each other.

If the file specified with path doesn't exist, it will be created.`,
    input_schema: {
      type: "object",
      properties: {
        path: {
          type: "string",
          description: "The path to the file",
        },
        old_str: {
          type: "string",
          description:
            "Text to search for - must match exactly and must only have one match exactly",
        },
        new_str: {
          type: "string",
          description: "Text to replace old_str with",
        },
      },
      required: ["path", "old_str", "new_str"],
    },
  },
];

// =============================================================================
// TOOL IMPLEMENTATIONS
// =============================================================================

async function walkDirectory(dir) {
  const files = [];

  async function walk(currentPath, relativeTo) {
    const entries = await fs.readdir(currentPath, { withFileTypes: true });

    for (const entry of entries) {
      const fullPath = path.join(currentPath, entry.name);
      const relPath = path.relative(relativeTo, fullPath);

      if (entry.isDirectory()) {
        files.push(relPath + "/");
        await walk(fullPath, relativeTo);
      } else {
        files.push(relPath);
      }
    }
  }

  await walk(dir, dir);
  return files;
}

// editFile implements search/replace editing.
// This is a simple but effective approach used by many coding agents.
async function editFile(filePath, oldStr, newStr) {
  // Validate inputs
  if (!filePath || oldStr === newStr) {
    throw new Error("Invalid input parameters");
  }

  let content;
  try {
    content = await fs.readFile(filePath, "utf-8");
  } catch (error) {
    // File doesn't exist - create it if old_str is empty (create mode)
    if (error.code === "ENOENT" && oldStr === "") {
      // Create parent directories if they don't exist
      const dir = path.dirname(filePath);
      if (dir !== ".") {
        await fs.mkdir(dir, { recursive: true });
      }
      await fs.writeFile(filePath, newStr, "utf-8");
      return `Successfully created file ${filePath}`;
    }
    throw error;
  }

  // Perform the replacement
  const newContent = content.replace(oldStr, newStr);

  // Verify the replacement happened
  if (content === newContent && oldStr !== "") {
    throw new Error("old_str not found in file");
  }

  // Write the modified content
  await fs.writeFile(filePath, newContent, "utf-8");
  return "OK";
}

async function executeTool(name, input) {
  try {
    if (name === "read_file") {
      const content = await fs.readFile(input.path, "utf-8");
      return { result: content, isError: false };
    }

    if (name === "list_files") {
      const dir = input.path || ".";
      const files = await walkDirectory(dir);
      return { result: JSON.stringify(files), isError: false };
    }

    if (name === "edit_file") {
      const result = await editFile(input.path, input.old_str, input.new_str);
      return { result, isError: false };
    }

    return { result: "Tool not found", isError: true };
  } catch (error) {
    return { result: error.message, isError: true };
  }
}

// =============================================================================
// AGENT
// =============================================================================

// The Agent class is unchanged from step 3.
// The same loop handles any number of tools!

class Agent {
  constructor() {
    this.conversation = [];
  }

  async runInference() {
    const message = await client.messages.create({
      model: "claude-opus-4-5-20251101",
      max_tokens: 1024,
      messages: this.conversation,
      tools: tools,
    });
    return message;
  }

  async run() {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
    });

    const prompt = (query) =>
      new Promise((resolve) => rl.question(query, resolve));

    console.log("Chat with Claude (use 'ctrl-c' to quit)");

    let readUserInput = true;

    try {
      while (true) {
        if (readUserInput) {
          const userInput = await prompt("\x1b[94mYou\x1b[0m: ");
          this.conversation.push({
            role: "user",
            content: userInput,
          });
        }

        const message = await this.runInference();

        this.conversation.push({
          role: "assistant",
          content: message.content,
        });

        const toolResults = [];

        for (const block of message.content) {
          if (block.type === "text") {
            console.log(`\x1b[93mClaude\x1b[0m: ${block.text}`);
          } else if (block.type === "tool_use") {
            console.log(
              `\x1b[92mtool\x1b[0m: ${block.name}(${JSON.stringify(block.input)})`
            );
            const { result, isError } = await executeTool(
              block.name,
              block.input
            );
            toolResults.push({
              type: "tool_result",
              tool_use_id: block.id,
              content: result,
              is_error: isError,
            });
          }
        }

        if (toolResults.length === 0) {
          readUserInput = true;
          continue;
        }

        readUserInput = false;
        this.conversation.push({
          role: "user",
          content: toolResults,
        });
      }
    } finally {
      rl.close();
    }
  }
}

const agent = new Agent();
agent.run().catch(console.error);
