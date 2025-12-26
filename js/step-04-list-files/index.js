// Step 4: Multiple Tools - Adding list_files
//
// MILESTONE: Give Claude a second tool to explore the filesystem.
// This shows how easy it is to add more capabilities to your agent.
//
// Key concepts:
// - Adding tools is just adding to the tools array
// - Each tool follows the same pattern: definition + implementation
// - Claude can now explore directories to find files, then read them
//
// With read_file + list_files, Claude can navigate and understand codebases!

import Anthropic from "@anthropic-ai/sdk";
import * as readline from "readline";
import * as fs from "fs/promises";
import * as path from "path";

const client = new Anthropic();

// =============================================================================
// TOOL DEFINITIONS
// =============================================================================

// NEW: Two tools! Adding capabilities is as simple as adding to this array.
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
    // NEW: list_files tool - complements read_file for exploring codebases
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
];

// =============================================================================
// TOOL IMPLEMENTATIONS
// =============================================================================

// Recursively walk a directory and return all file/folder paths
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

async function executeTool(name, input) {
  if (name === "read_file") {
    try {
      const content = await fs.readFile(input.path, "utf-8");
      return { result: content, isError: false };
    } catch (error) {
      return { result: error.message, isError: true };
    }
  }

  if (name === "list_files") {
    try {
      // Default to current directory if no path provided
      const dir = input.path || ".";
      const files = await walkDirectory(dir);
      // Return as JSON array - structured data is easier for Claude to work with
      return { result: JSON.stringify(files), isError: false };
    } catch (error) {
      return { result: error.message, isError: true };
    }
  }

  return { result: "Tool not found", isError: true };
}

// =============================================================================
// AGENT
// =============================================================================

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
