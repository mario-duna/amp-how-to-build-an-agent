// Step 2: Interactive Chatbot - The Conversation Loop
//
// MILESTONE: Build an interactive chat that maintains conversation history.
// This introduces the core "agentic loop" pattern - though without tools yet.
//
// Key concepts:
// - The agent loop: read input -> call LLM -> display output -> repeat
// - Conversation history: appending messages to maintain context
// - Separating concerns: Agent struct encapsulates the chat logic
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
// Each message contains CONTENT BLOCKS. In this step, we only see:
//
//   TYPE: "text"      - Plain text content (user input or Claude's response)
//
// The conversation array alternates: user, assistant, user, assistant...
// Claude is STATELESS - we must send the full conversation history each time.

package main

import (
	"bufio"
	"context"
	"fmt"
	"os"

	"github.com/anthropics/anthropic-sdk-go"
)

func main() {
	client := anthropic.NewClient()

	// Set up user input reading from stdin
	scanner := bufio.NewScanner(os.Stdin)
	getUserMessage := func() (string, bool) {
		if !scanner.Scan() {
			return "", false
		}
		return scanner.Text(), true
	}

	// Create and run the agent
	agent := NewAgent(&client, getUserMessage)
	err := agent.Run(context.TODO())
	if err != nil {
		fmt.Printf("Error: %s\n", err.Error())
	}
}

// NewAgent creates a new Agent instance.
// The agent encapsulates the Claude client and user input function.
func NewAgent(client *anthropic.Client, getUserMessage func() (string, bool)) *Agent {
	return &Agent{
		client:         client,
		getUserMessage: getUserMessage,
	}
}

// Agent holds the state needed for a chat session.
type Agent struct {
	client         *anthropic.Client
	getUserMessage func() (string, bool)
}

// Run starts the main conversation loop.
// This is the heart of any agent: a loop that processes input and generates responses.
func (a *Agent) Run(ctx context.Context) error {
	// Conversation history - this is what gives Claude "memory" of the chat.
	// Each message (user and assistant) gets appended here.
	//
	// Example conversation array after a few turns:
	//   [0] {Role: "user",      Content: [{Type: "text", Text: "Hi!"}]}
	//   [1] {Role: "assistant", Content: [{Type: "text", Text: "Hello!"}]}
	//   [2] {Role: "user",      Content: [{Type: "text", Text: "How are you?"}]}
	//   [3] {Role: "assistant", Content: [{Type: "text", Text: "I'm doing well!"}]}
	conversation := []anthropic.MessageParam{}

	fmt.Println("Chat with Claude (use 'ctrl-c' to quit)")

	// THE AGENT LOOP: This pattern is fundamental to all agents.
	// 1. Get user input
	// 2. Add to conversation history
	// 3. Call the LLM
	// 4. Add response to history
	// 5. Display response
	// 6. Repeat
	for {
		// Step 1: Get user input
		fmt.Print("\u001b[94mYou\u001b[0m: ")
		userInput, ok := a.getUserMessage()
		if !ok {
			break
		}

		// Step 2: Add user message to conversation history
		// Creates: {Role: "user", Content: [{Type: "text", Text: userInput}]}
		userMessage := anthropic.NewUserMessage(anthropic.NewTextBlock(userInput))
		conversation = append(conversation, userMessage)

		// Step 3: Call the LLM with full conversation history
		message, err := a.runInference(ctx, conversation)
		if err != nil {
			return err
		}

		// Step 4: Add Claude's response to conversation history
		// This is crucial - Claude needs to see its own previous responses
		// Creates: {Role: "assistant", Content: [{Type: "text", Text: "..."}]}
		conversation = append(conversation, message.ToParam())

		// Step 5: Display the response
		for _, content := range message.Content {
			switch content.Type {
			case "text":
				fmt.Printf("\u001b[93mClaude\u001b[0m: %s\n", content.Text)
			}
		}
		// Step 6: Loop continues...
	}

	return nil
}

// runInference sends the conversation to Claude and returns the response.
func (a *Agent) runInference(ctx context.Context, conversation []anthropic.MessageParam) (*anthropic.Message, error) {
	message, err := a.client.Messages.New(ctx, anthropic.MessageNewParams{
		Model:     "claude-opus-4-5-20251101",
		MaxTokens: int64(1024),
		// Pass the entire conversation history - this is how Claude maintains context
		Messages: conversation,
	})
	return message, err
}
