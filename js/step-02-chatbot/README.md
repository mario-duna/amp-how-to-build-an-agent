# Step 02: Interactive Chatbot

Build an interactive chat that maintains conversation history.

## What You Learn

- The agent loop pattern
- Maintaining conversation history
- Multi-turn conversations

## How It Works

```mermaid
flowchart TD
    Start([Start]) --> Loop

    subgraph Loop [Agent Loop]
        A[Get user input] --> B[Add to conversation history]
        B --> C[Call Claude API]
        C --> D[Add response to history]
        D --> E[Display response]
        E --> A
    end

    Loop --> |Ctrl+C| End([End])
```

## Conversation History

The key insight: Claude is stateless. To maintain context, we send the **entire conversation** with each request.

```mermaid
sequenceDiagram
    participant User
    participant Agent
    participant Claude

    User->>Agent: "Hi, I'm Alice"
    Agent->>Claude: [user: "Hi, I'm Alice"]
    Claude-->>Agent: "Hello Alice!"

    User->>Agent: "What's my name?"
    Agent->>Claude: [user: "Hi, I'm Alice", assistant: "Hello Alice!", user: "What's my name?"]
    Claude-->>Agent: "Your name is Alice"

    Note over Agent: History grows with each turn
```

## Run It

```bash
mise run js:step-02
```
