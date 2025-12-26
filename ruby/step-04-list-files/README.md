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

    User->>Claude: "Summarize all Ruby files"

    Claude->>list_files: list_files(".")
    list_files-->>Claude: ["main.rb", "Gemfile", ...]

    Claude->>read_file: read_file("main.rb")
    read_file-->>Claude: contents of main.rb

    Claude->>read_file: read_file("Gemfile")
    read_file-->>Claude: contents of Gemfile

    Claude->>User: "Here's a summary..."
```

## Code Change

The only code change from Step 03:

```ruby
# Step 03
TOOLS = [read_file_tool]

# Step 04 - just add to the array!
TOOLS = [read_file_tool, list_files_tool]
```

## Run It

```bash
mise run ruby:step-04
```

Try asking: "What files are in this directory?" or "Find and read all .rb files"
