// Step 2: Interactive Chatbot - The Conversation Loop
//
// MILESTONE: Build an interactive chat that maintains conversation history.
// This introduces the core "agentic loop" pattern - though without tools yet.
//
// Key concepts:
// - The agent loop: read input -> call LLM -> display output -> repeat
// - Conversation history: appending messages to maintain context
// - Separating concerns: Agent class encapsulates the chat logic
//
// =============================================================================
// MESSAGE TYPES IN THE ANTHROPIC API
// =============================================================================
//
// The API uses a conversation model with two roles:
//
//   ROLE: "user"      - Messages from the human (or tool results, as we'll see in step 3)
//   ROLE: "assistant" - Messages from Claude
//
// Each message contains CONTENT. In this step, we only see:
//
//   TYPE: "text"      - Plain text content (user input or Claude's response)
//
// The conversation array alternates: user, assistant, user, assistant...
// Claude is STATELESS - we must send the full conversation history each time.

import Anthropic from "@anthropic-ai/sdk";
import * as readline from "readline";

const client = new Anthropic();

// Agent class holds the state needed for a chat session.
class Agent {
  constructor() {
    // Conversation history - this is what gives Claude "memory" of the chat.
    // Each message (user and assistant) gets appended here.
    //
    // Example conversation array after a few turns:
    //   [0] {role: "user",      content: "Hi!"}
    //   [1] {role: "assistant", content: "Hello!"}
    //   [2] {role: "user",      content: "How are you?"}
    //   [3] {role: "assistant", content: "I'm doing well!"}
    this.conversation = [];
  }

  // runInference sends the conversation to Claude and returns the response.
  async runInference() {
    const message = await client.messages.create({
      model: "claude-opus-4-5-20251101",
      max_tokens: 1024,
      // Pass the entire conversation history - this is how Claude maintains context
      messages: this.conversation,
    });
    return message;
  }

  // run starts the main conversation loop.
  // This is the heart of any agent: a loop that processes input and generates responses.
  async run() {
    // Set up user input reading from stdin
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
    });

    const prompt = (query) =>
      new Promise((resolve) => rl.question(query, resolve));

    console.log("Chat with Claude (use 'ctrl-c' to quit)");

    // THE AGENT LOOP: This pattern is fundamental to all agents.
    // 1. Get user input
    // 2. Add to conversation history
    // 3. Call the LLM
    // 4. Add response to history
    // 5. Display response
    // 6. Repeat
    try {
      while (true) {
        // Step 1: Get user input
        const userInput = await prompt("\x1b[94mYou\x1b[0m: ");

        // Step 2: Add user message to conversation history
        // Creates: {role: "user", content: userInput}
        this.conversation.push({
          role: "user",
          content: userInput,
        });

        // Step 3: Call the LLM with full conversation history
        const message = await this.runInference();

        // Step 4: Add Claude's response to conversation history
        // This is crucial - Claude needs to see its own previous responses
        // Creates: {role: "assistant", content: [...]}
        this.conversation.push({
          role: "assistant",
          content: message.content,
        });

        // Step 5: Display the response
        for (const block of message.content) {
          if (block.type === "text") {
            console.log(`\x1b[93mClaude\x1b[0m: ${block.text}`);
          }
        }
        // Step 6: Loop continues...
      }
    } finally {
      rl.close();
    }
  }
}

// Create and run the agent
const agent = new Agent();
agent.run().catch(console.error);
