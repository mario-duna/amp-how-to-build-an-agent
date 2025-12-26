# Step 04: Multiple Tools - list_files

Add a second tool so Claude can explore the filesystem.

## What You Learn

- Adding multiple tools is trivial
- Tools work together naturally
- Claude decides which tool to use

## Available Tools

![Tools](https://mermaid.ink/img/Zmxvd2NoYXJ0IExSCiAgICBDbGF1ZGUgLS0-fGNob29zZXwgQVtyZWFkX2ZpbGVdCiAgICBDbGF1ZGUgLS0-fGNob29zZXwgQltsaXN0X2ZpbGVzXQogICAgQSAtLT4gRlNbKEZpbGUgU3lzdGVtKV0KICAgIEIgLS0-IEZT)

## How Claude Uses Multiple Tools

Claude can chain tools together to accomplish complex tasks:

![Tool Chaining](https://mermaid.ink/img/c2VxdWVuY2VEaWFncmFtCiAgICBwYXJ0aWNpcGFudCBVc2VyCiAgICBwYXJ0aWNpcGFudCBDbGF1ZGUKICAgIHBhcnRpY2lwYW50IGxpc3RfZmlsZXMKICAgIHBhcnRpY2lwYW50IHJlYWRfZmlsZQogICAgVXNlci0-PkNsYXVkZTogU3VtbWFyaXplIGFsbCBHbyBmaWxlcwogICAgQ2xhdWRlLT4-bGlzdF9maWxlczogbGlzdF9maWxlcyAuCiAgICBsaXN0X2ZpbGVzLS0-PkNsYXVkZTogbWFpbi5nbywgZ28ubW9kLCAuLi4KICAgIENsYXVkZS0-PnJlYWRfZmlsZTogcmVhZF9maWxlIG1haW4uZ28KICAgIHJlYWRfZmlsZS0tPj5DbGF1ZGU6IGNvbnRlbnRzIG9mIG1haW4uZ28KICAgIENsYXVkZS0-PnJlYWRfZmlsZTogcmVhZF9maWxlIGdvLm1vZAogICAgcmVhZF9maWxlLS0-PkNsYXVkZTogY29udGVudHMgb2YgZ28ubW9kCiAgICBDbGF1ZGUtPj5Vc2VyOiBIZXJlIGlzIGEgc3VtbWFyeS4uLg)

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
