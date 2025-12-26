package main

import (
	"context"
	"fmt"

	"github.com/anthropics/anthropic-sdk-go"
)

func main() {
	client := anthropic.NewClient()
	message, err := client.Messages.New(context.TODO(), anthropic.MessageNewParams{
		MaxTokens: 1024,
		Messages: []anthropic.MessageParam{{
			Content: []anthropic.ContentBlockParamUnion{{
				OfText: &anthropic.TextBlockParam{Text: "What is a quaternion?"},
			}},
			Role: anthropic.MessageParamRoleUser,
		}},
		Model: anthropic.ModelClaude3_7SonnetLatest,
	})
	if err != nil {
		panic(err.Error())
	}
	fmt.Printf("%+v\n", message.Content)
}
