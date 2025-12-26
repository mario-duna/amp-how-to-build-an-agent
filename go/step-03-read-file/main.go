// Step 3: Adding Tools - The read_file Tool
//
// MILESTONE: Give Claude the ability to read files from the filesystem.
// This is where the chatbot becomes an AGENT - it can now take actions!
//
// Key concepts:
// - Tool definitions: telling Claude what tools exist and how to use them
// - Tool execution: actually running the tool when Claude requests it
// - The tool loop: Claude may need multiple tool calls before responding
// - JSON Schema: how tools describe their parameters to Claude
//
// What makes this an "agent"?
// An agent is an LLM that can take actions in the world. By giving Claude
// the read_file tool, it can now access information outside its context window.

package main

import (
	"bufio"
	"context"
	"encoding/json"
	"fmt"
	"os"

	"github.com/anthropics/anthropic-sdk-go"
	"github.com/invopop/jsonschema"
)

func main() {
	client := anthropic.NewClient()

	scanner := bufio.NewScanner(os.Stdin)
	getUserMessage := func() (string, bool) {
		if !scanner.Scan() {
			return "", false
		}
		return scanner.Text(), true
	}

	// NEW: Define the tools available to the agent.
	// This is how we give Claude capabilities beyond just chatting.
	tools := []ToolDefinition{ReadFileDefinition}
	agent := NewAgent(&client, getUserMessage, tools)
	err := agent.Run(context.TODO())
	if err != nil {
		fmt.Printf("Error: %s\n", err.Error())
	}
}

func NewAgent(
	client *anthropic.Client,
	getUserMessage func() (string, bool),
	tools []ToolDefinition,
) *Agent {
	return &Agent{
		client:         client,
		getUserMessage: getUserMessage,
		tools:          tools,
	}
}

type Agent struct {
	client         *anthropic.Client
	getUserMessage func() (string, bool)
	tools          []ToolDefinition // NEW: Agent now has tools
}

func (a *Agent) Run(ctx context.Context) error {
	conversation := []anthropic.MessageParam{}

	fmt.Println("Chat with Claude (use 'ctrl-c' to quit)")

	// NEW: readUserInput flag controls whether we wait for user input.
	// When Claude uses a tool, we need to send the result back without
	// waiting for the user - this enables multi-step tool use.
	readUserInput := true
	for {
		if readUserInput {
			fmt.Print("\u001b[94mYou\u001b[0m: ")
			userInput, ok := a.getUserMessage()
			if !ok {
				break
			}

			userMessage := anthropic.NewUserMessage(anthropic.NewTextBlock(userInput))
			conversation = append(conversation, userMessage)
		}

		message, err := a.runInference(ctx, conversation)
		if err != nil {
			return err
		}
		conversation = append(conversation, message.ToParam())

		// NEW: Process Claude's response, which may contain tool calls.
		// Claude can respond with text, tool_use, or both!
		toolResults := []anthropic.ContentBlockParamUnion{}
		for _, content := range message.Content {
			switch content.Type {
			case "text":
				// Regular text response - display it
				fmt.Printf("\u001b[93mClaude\u001b[0m: %s\n", content.Text)
			case "tool_use":
				// NEW: Claude wants to use a tool!
				// Execute the tool and collect the result
				result := a.executeTool(content.ID, content.Name, content.Input)
				toolResults = append(toolResults, result)
			}
		}

		// NEW: If there were tool calls, send results back to Claude.
		// Don't wait for user input - let Claude process the results.
		if len(toolResults) == 0 {
			readUserInput = true
			continue
		}
		readUserInput = false
		// Tool results are sent as a "user" message (this is the API convention)
		conversation = append(conversation, anthropic.NewUserMessage(toolResults...))
	}

	return nil
}

// executeTool finds and runs the requested tool, returning the result.
// This is the bridge between Claude's request and actual code execution.
func (a *Agent) executeTool(id, name string, input json.RawMessage) anthropic.ContentBlockParamUnion {
	// Find the tool by name
	var toolDef ToolDefinition
	var found bool
	for _, tool := range a.tools {
		if tool.Name == name {
			toolDef = tool
			found = true
			break
		}
	}
	if !found {
		return anthropic.NewToolResultBlock(id, "tool not found", true)
	}

	// Execute the tool and display what's happening
	fmt.Printf("\u001b[92mtool\u001b[0m: %s(%s)\n", name, input)
	response, err := toolDef.Function(input)
	if err != nil {
		// Return errors to Claude - it can often recover and try differently
		return anthropic.NewToolResultBlock(id, err.Error(), true)
	}
	return anthropic.NewToolResultBlock(id, response, false)
}

// runInference now includes tools in the API request.
func (a *Agent) runInference(ctx context.Context, conversation []anthropic.MessageParam) (*anthropic.Message, error) {
	// Convert our tool definitions to the Anthropic API format
	anthropicTools := []anthropic.ToolUnionParam{}
	for _, tool := range a.tools {
		anthropicTools = append(anthropicTools, anthropic.ToolUnionParam{
			OfTool: &anthropic.ToolParam{
				Name:        tool.Name,
				Description: anthropic.String(tool.Description),
				InputSchema: tool.InputSchema,
			},
		})
	}

	message, err := a.client.Messages.New(ctx, anthropic.MessageNewParams{
		Model:     "claude-opus-4-5-20251101",
		MaxTokens: int64(1024),
		Messages:  conversation,
		Tools:     anthropicTools, // NEW: Tell Claude about available tools
	})
	return message, err
}

// =============================================================================
// TOOL DEFINITIONS
// =============================================================================

// ToolDefinition describes a tool that Claude can use.
// It includes everything Claude needs to know to use the tool correctly:
// - Name: how Claude refers to the tool
// - Description: when and why to use it (this is very important!)
// - InputSchema: what parameters the tool accepts (JSON Schema format)
// - Function: the actual Go function to execute
type ToolDefinition struct {
	Name        string                         `json:"name"`
	Description string                         `json:"description"`
	InputSchema anthropic.ToolInputSchemaParam `json:"input_schema"`
	Function    func(input json.RawMessage) (string, error)
}

// ReadFileDefinition defines the read_file tool.
// The description is crucial - it tells Claude when to use this tool.
var ReadFileDefinition = ToolDefinition{
	Name:        "read_file",
	Description: "Read the contents of a given relative file path. Use this when you want to see what's inside a file. Do not use this with directory names.",
	InputSchema: ReadFileInputSchema,
	Function:    ReadFile,
}

// ReadFileInput defines the parameters for read_file.
// The jsonschema_description tag becomes part of the schema Claude sees.
type ReadFileInput struct {
	Path string `json:"path" jsonschema_description:"The relative path of a file in the working directory."`
}

var ReadFileInputSchema = GenerateSchema[ReadFileInput]()

// ReadFile is the actual implementation of the read_file tool.
// It reads a file and returns its contents as a string.
func ReadFile(input json.RawMessage) (string, error) {
	readFileInput := ReadFileInput{}
	err := json.Unmarshal(input, &readFileInput)
	if err != nil {
		panic(err)
	}

	content, err := os.ReadFile(readFileInput.Path)
	if err != nil {
		return "", err
	}
	return string(content), nil
}

// =============================================================================
// JSON SCHEMA GENERATION
// =============================================================================

// GenerateSchema creates a JSON Schema from a Go struct.
// Claude needs JSON Schema format to understand tool parameters.
// This helper uses reflection to automatically generate it from struct tags.
func GenerateSchema[T any]() anthropic.ToolInputSchemaParam {
	reflector := jsonschema.Reflector{
		AllowAdditionalProperties: false,
		DoNotReference:            true,
	}
	var v T

	schema := reflector.Reflect(v)

	return anthropic.ToolInputSchemaParam{
		Properties: schema.Properties,
	}
}
