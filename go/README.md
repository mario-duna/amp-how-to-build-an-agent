# How to Build an Agent - Go Implementation

Code extracted from [How to Build an Agent](https://ampcode.com/how-to-build-an-agent) by Thorsten Ball.

## Quick Start (with mise)

From the project root:
```bash
mise run go:run
```

See the [main README](../README.md) for full mise setup instructions.

## Manual Setup

If not using mise:

1. Install Go 1.23+
2. Set your API key:
   ```bash
   export ANTHROPIC_API_KEY="your-key-here"
   ```
3. Install dependencies:
   ```bash
   go mod tidy
   ```
4. Run any step:
   ```bash
   cd step-05-edit-file && go run main.go
   ```

## Steps

| Step | Description | Tools |
|------|-------------|-------|
| 01 | First API call to Claude | - |
| 02 | Interactive chatbot with conversation history | - |
| 03 | Adding tools - Claude can read files | `read_file` |
| 04 | Multiple tools - Claude can explore directories | `read_file`, `list_files` |
| 05 | Complete agent - Claude can edit files | `read_file`, `list_files`, `edit_file` |

Each step's code is heavily commented explaining the key concepts and what each block does.
