# How to Build an Agent - Go Implementation

Code extracted from [How to Build an Agent](https://ampcode.com/how-to-build-an-agent) by Thorsten Ball.

## Prerequisites

- Go 1.23 or higher
- An Anthropic API key

## Setup

1. Copy `env.example.sh` to `env.sh` and add your Anthropic API key:
   ```bash
   cp env.example.sh env.sh
   # Edit env.sh and add your API key
   ```

2. Source the environment file:
   ```bash
   source ./env.sh
   ```

3. Install dependencies:
   ```bash
   go mod tidy
   ```

## Running the Steps

Each step is a standalone, runnable checkpoint that builds upon the previous one:

### Step 00: Hello World
Basic Go program - just prints "hello world".
```bash
cd step-00-hello-world && go run main.go
```

### Step 01: Hello Claude
First API call to Claude - asks "What is a quaternion?" and prints the response.
```bash
cd step-01-hello-claude && go run main.go
```

### Step 02: Chatbot
Interactive chatbot - maintains conversation history with Claude.
```bash
cd step-02-chatbot && go run main.go
```

### Step 03: Read File Tool
Adds the `read_file` tool - Claude can now read files from your filesystem.
```bash
cd step-03-read-file && go run main.go
```

### Step 04: List Files Tool
Adds the `list_files` tool - Claude can now list directory contents.
```bash
cd step-04-list-files && go run main.go
```

### Step 05: Edit File Tool (Full Agent)
Adds the `edit_file` tool - Claude can now create and edit files. This is the complete agent.
```bash
cd step-05-edit-file && go run main.go
```

## What Each Step Demonstrates

| Step | Description | Tools Available |
|------|-------------|-----------------|
| 00 | Basic Go program | None |
| 01 | Single API call | None |
| 02 | Conversation loop | None |
| 03 | Tool use basics | `read_file` |
| 04 | Multiple tools | `read_file`, `list_files` |
| 05 | Complete agent | `read_file`, `list_files`, `edit_file` |
