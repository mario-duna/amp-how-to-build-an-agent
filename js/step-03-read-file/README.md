# Step 03: Adding Tools - read_file

This is where the chatbot becomes an **agent** - it can now take actions!

## What You Learn

- Defining tools for Claude
- Executing tool calls
- The tool use loop
- JSON Schema for parameters

## What Makes This an Agent?

An agent is an LLM that can **take actions** in the world. By giving Claude the `read_file` tool, it can now access information outside its context window.

```mermaid
flowchart LR
    subgraph Before[Chatbot]
        A[User] <--> B[Claude]
    end

    subgraph After[Agent]
        C[User] <--> D[Claude]
        D <--> E[Tools]
        E <--> F[File System]
    end
```

## How Tool Use Works

```mermaid
sequenceDiagram
    participant User
    participant Agent
    participant Claude
    participant Tool

    User->>Agent: "What's in config.json?"
    Agent->>Claude: Send message + tool definitions
    Claude-->>Agent: tool_use: read_file("config.json")
    Agent->>Tool: Execute read_file
    Tool-->>Agent: File contents
    Agent->>Claude: Send tool result
    Claude-->>Agent: "The config file contains..."
    Agent->>User: Display response
```

## The Enhanced Agent Loop

```mermaid
flowchart TD
    A[Get user input] --> B[Add to conversation]
    B --> C[Call Claude with tools]
    C --> D{Response type?}

    D -->|text| E[Display to user]
    D -->|tool_use| F[Execute tool]

    F --> G[Add result to conversation]
    G --> C

    E --> A
```

## Tool Definition Structure

```mermaid
flowchart LR
    subgraph ToolDefinition
        A[name: read_file]
        B[description: When to use it]
        C[input_schema: Parameters]
    end
```

## Run It

```bash
mise run js:step-03
```

Try asking: "What's in index.js?" or "Read the package.json file"
