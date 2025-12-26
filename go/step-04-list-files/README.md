# Step 04: Multiple Tools - list_files

Add a second tool so Claude can explore the filesystem.

## What You Learn

- Adding multiple tools is trivial
- Tools work together naturally
- Claude decides which tool to use

## Available Tools

```mermaid
flowchart LR
    Claude --> |choose| Tools

    subgraph Tools
        A[read_file<br/>Read file contents]
        B[list_files<br/>List directory]
    end

    A --> FS[(File System)]
    B --> FS
```

## How Claude Uses Multiple Tools

Claude can chain tools together to accomplish complex tasks:

```mermaid
sequenceDiagram
    participant User
    participant Claude
    participant list_files
    participant read_file

    User->>Claude: "Summarize all Go files"

    Claude->>list_files: list_files(".")
    list_files-->>Claude: ["main.go", "go.mod", ...]

    Claude->>read_file: read_file("main.go")
    read_file-->>Claude: contents of main.go

    Claude->>read_file: read_file("go.mod")
    read_file-->>Claude: contents of go.mod

    Claude->>User: "Here's a summary..."
```

## Code Change

The only code change from Step 03:

```go
// Step 03
tools := []ToolDefinition{ReadFileDefinition}

// Step 04 - just add to the slice!
tools := []ToolDefinition{ReadFileDefinition, ListFilesDefinition}
```

## Run It

```bash
mise run go:step-04
```

Try asking: "What files are in this directory?" or "Find and read all .go files"
