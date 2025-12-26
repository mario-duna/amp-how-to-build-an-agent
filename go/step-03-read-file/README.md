# Step 03: Adding Tools - read_file

This is where the chatbot becomes an **agent** - it can now take actions!

## What You Learn

- Defining tools for Claude
- Executing tool calls
- The tool use loop
- JSON Schema for parameters

## What Makes This an Agent?

An agent is an LLM that can **take actions** in the world. By giving Claude the `read_file` tool, it can now access information outside its context window.

![Chatbot vs Agent](https://mermaid.ink/img/Zmxvd2NoYXJ0IExSCiAgICBzdWJncmFwaCBCZWZvcmVbQ2hhdGJvdF0KICAgICAgICBBW1VzZXJdIDwtLT4gQltDbGF1ZGVdCiAgICBlbmQKICAgIHN1YmdyYXBoIEFmdGVyW0FnZW50XQogICAgICAgIENbVXNlcl0gPC0tPiBEW0NsYXVkZV0KICAgICAgICBEIDwtLT4gRVtUb29sc10KICAgICAgICBFIDwtLT4gRltGaWxlIFN5c3RlbV0KICAgIGVuZA)

## How Tool Use Works

![Tool Use Flow](https://mermaid.ink/img/c2VxdWVuY2VEaWFncmFtCiAgICBwYXJ0aWNpcGFudCBVc2VyCiAgICBwYXJ0aWNpcGFudCBBZ2VudAogICAgcGFydGljaXBhbnQgQ2xhdWRlCiAgICBwYXJ0aWNpcGFudCBUb29sCiAgICBVc2VyLT4-QWdlbnQ6IFdoYXRzIGluIGNvbmZpZy5qc29uPwogICAgQWdlbnQtPj5DbGF1ZGU6IFNlbmQgbWVzc2FnZSArIHRvb2wgZGVmaW5pdGlvbnMKICAgIENsYXVkZS0tPj5BZ2VudDogdG9vbF91c2U6IHJlYWRfZmlsZSBjb25maWcuanNvbgogICAgQWdlbnQtPj5Ub29sOiBFeGVjdXRlIHJlYWRfZmlsZQogICAgVG9vbC0tPj5BZ2VudDogRmlsZSBjb250ZW50cwogICAgQWdlbnQtPj5DbGF1ZGU6IFNlbmQgdG9vbCByZXN1bHQKICAgIENsYXVkZS0tPj5BZ2VudDogVGhlIGNvbmZpZyBmaWxlIGNvbnRhaW5zLi4uCiAgICBBZ2VudC0-PlVzZXI6IERpc3BsYXkgcmVzcG9uc2U)

## The Enhanced Agent Loop

![Enhanced Loop](https://mermaid.ink/img/Zmxvd2NoYXJ0IFRECiAgICBBW0dldCB1c2VyIGlucHV0XSAtLT4gQltBZGQgdG8gY29udmVyc2F0aW9uXQogICAgQiAtLT4gQ1tDYWxsIENsYXVkZSB3aXRoIHRvb2xzXQogICAgQyAtLT4gRHtSZXNwb25zZSB0eXBlP30KICAgIEQgLS0-fHRleHR8IEVbRGlzcGxheSB0byB1c2VyXQogICAgRCAtLT58dG9vbF91c2V8IEZbRXhlY3V0ZSB0b29sXQogICAgRiAtLT4gR1tBZGQgcmVzdWx0IHRvIGNvbnZlcnNhdGlvbl0KICAgIEcgLS0-IEMKICAgIEUgLS0-IEE)

## Run It

```bash
mise run go:step-03
```

Try asking: "What's in main.go?" or "Read the go.mod file"
