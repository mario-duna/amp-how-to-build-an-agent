# Step 01: Hello Claude

Your first API call to Claude - the foundation of everything.

## What You Learn

- Creating an Anthropic client
- Structuring a message request
- Handling the response

## How It Works

```mermaid
sequenceDiagram
    participant App
    participant Claude API

    App->>Claude API: Send message request
    Note right of App: "What is a quaternion?"
    Claude API-->>App: Return response
    Note left of Claude API: Text response
    App->>App: Print response
```

## Key Components

```mermaid
flowchart LR
    subgraph Request
        A[max_tokens]
        B[messages]
        C[model]
    end

    subgraph Response
        D[content blocks]
    end

    Request --> API[Claude API] --> Response
```

## Run It

```bash
mise run ruby:step-01
```
