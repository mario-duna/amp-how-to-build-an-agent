# How to Build an Agent

Code extracted from [How to Build an Agent](https://ampcode.com/how-to-build-an-agent) by Thorsten Ball.

This repository contains runnable implementations of the tutorial in multiple languages:

- [Go](./go/) - Complete

## Prerequisites

- [mise](https://mise.jdx.dev/) - handles language installation and task running
- An [Anthropic API key](https://console.anthropic.com/)

## Quick Start

1. Install mise (if not already installed):
   ```bash
   curl https://mise.run | sh
   ```

2. Clone and setup:
   ```bash
   git clone <repo-url>
   cd amp-how-to-build-an-agent
   mise trust
   mise install
   ```

3. Configure your API key:
   ```bash
   mise run setup        # Creates .env from template
   # Edit .env and add your ANTHROPIC_API_KEY
   ```

4. Run the complete agent:
   ```bash
   mise run go:run
   ```

## Available Tasks

List all available tasks:
```bash
mise tasks
```

### Setup Tasks

| Task | Description |
|------|-------------|
| `mise run setup` | Create `.env` file from template (if it doesn't exist) |
| `mise run check-env` | Verify `ANTHROPIC_API_KEY` is configured |

### Go Tasks

| Task | Description |
|------|-------------|
| `mise run go:deps` | Install Go dependencies |
| `mise run go:run` | Run the complete agent |
| `mise run go:step-01` | Single API call to Claude |
| `mise run go:step-02` | Interactive chatbot |
| `mise run go:step-03` | Agent with `read_file` tool |
| `mise run go:step-04` | Agent with `read_file` + `list_files` tools |
| `mise run go:step-05` | Complete agent with all tools |

All `go:*` tasks automatically check that your API key is configured before running.

## Tutorial Steps

Each step builds upon the previous one:

| Step | What You Learn |
|------|----------------|
| 01 | Making your first API call to Claude |
| 02 | Building a conversation loop (the "agentic loop") |
| 03 | Adding tools - the `read_file` tool |
| 04 | Multiple tools - adding `list_files` |
| 05 | Complete agent - adding `edit_file` |

## Adding More Languages

This project is structured to support multiple language implementations. Each language gets its own folder with the same step structure.
