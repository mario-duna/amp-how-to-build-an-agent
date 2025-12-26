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
| 00 | Hello World | - |
| 01 | Single API call to Claude | - |
| 02 | Interactive chatbot | - |
| 03 | Tool use basics | `read_file` |
| 04 | Multiple tools | `read_file`, `list_files` |
| 05 | Complete agent | `read_file`, `list_files`, `edit_file` |
