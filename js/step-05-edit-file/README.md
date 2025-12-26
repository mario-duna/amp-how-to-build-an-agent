# Step 05: Complete Agent - edit_file

The final piece: Claude can now **create and modify files**.

## What You Learn

- File editing with search/replace
- Creating new files
- A complete coding agent in ~200 lines!

## The Complete Agent

```mermaid
flowchart TB
    User([User]) <--> Agent

    subgraph Agent[Complete Agent]
        Loop[Agent Loop]

        subgraph Tools
            RF[read_file<br/>Understand code]
            LF[list_files<br/>Explore codebase]
            EF[edit_file<br/>Make changes]
        end

        Loop <--> Tools
    end

    Tools <--> FS[(File System)]
```

## Agent Capabilities

| Capability | Tool | Example |
|-----------|------|---------|
| **Explore** | list_files | "What's in this project?" |
| **Understand** | read_file | "How does index.js work?" |
| **Modify** | edit_file | "Fix this bug" |

## The edit_file Tool

Uses search/replace for precise edits:

```mermaid
flowchart LR
    subgraph Input
        A[path: file.js]
        B[old_str: text to find]
        C[new_str: replacement]
    end

    subgraph Behavior
        D{old_str empty?}
        D -->|yes| E[Create new file<br/>with new_str content]
        D -->|no| F[Replace old_str<br/>with new_str]
    end

    Input --> Behavior
```

## Complete Agent Loop

```mermaid
flowchart TD
    Start([User Request]) --> A[Add to conversation]
    A --> B[Call Claude with all tools]
    B --> C{Response contains?}

    C -->|text| D[Display to user]
    C -->|tool_use| E{Which tool?}

    E -->|read_file| F[Read and return contents]
    E -->|list_files| G[List and return files]
    E -->|edit_file| H[Modify file]

    F --> I[Add result to conversation]
    G --> I
    H --> I
    I --> B

    D --> End([Wait for next request])
```

## Example: Bug Fix Workflow

```mermaid
sequenceDiagram
    participant User
    participant Claude
    participant Tools

    User->>Claude: "Fix the typo in index.js"

    Claude->>Tools: list_files(".")
    Tools-->>Claude: [index.js, ...]

    Claude->>Tools: read_file("index.js")
    Tools-->>Claude: File with typo

    Claude->>Tools: edit_file(path, old="teh", new="the")
    Tools-->>Claude: OK

    Claude->>User: "Fixed the typo 'teh' → 'the'"
```

## Run It

```bash
mise run js:step-05
```

Try asking:
- "Create a hello.txt file with a greeting"
- "Add a comment to index.js explaining what it does"
- "Find and fix any typos in the README"
