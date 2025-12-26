// Step 1: Hello Claude - Your First API Call
//
// MILESTONE: Make a single API call to Claude and get a response.
// This is the foundation - proving you can communicate with the LLM.
//
// Key concepts:
// - Creating an Anthropic client (uses ANTHROPIC_API_KEY env var)
// - Structuring a message request
// - Handling the response

package main

import (
	"context"
	"fmt"

	"github.com/anthropics/anthropic-sdk-go"
)

func main() {
	// Create a new Anthropic client.
	// The SDK automatically reads the ANTHROPIC_API_KEY environment variable.
	client := anthropic.NewClient()

	// Make a single API call to Claude.
	// This is the simplest possible interaction - one question, one answer.
	message, err := client.Messages.New(context.TODO(), anthropic.MessageNewParams{
		// MaxTokens limits the response length (required parameter)
		MaxTokens: 1024,

		// Messages is the conversation history - here just one user message
		Messages: []anthropic.MessageParam{{
			Content: []anthropic.ContentBlockParamUnion{{
				OfText: &anthropic.TextBlockParam{Text: "What is a quaternion?"},
			}},
			Role: anthropic.MessageParamRoleUser,
		}},

		// Model specifies which Claude model to use
		Model: "claude-opus-4-5-20251101",
	})
	if err != nil {
		panic(err.Error())
	}

	// Print Claude's response.
	// message.Content is an array of content blocks (usually just one text block)
	fmt.Printf("%+v\n", message.Content)
}
