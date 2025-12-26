# Step 05: Complete Agent - edit_file

The final piece: Claude can now **create and modify files**.

## What You Learn

- File editing with search/replace
- Creating new files
- A complete coding agent in ~300 lines!

## The Complete Agent

![Complete Agent](https://mermaid.ink/img/Zmxvd2NoYXJ0IFRCCiAgICBVc2VyKFtVc2VyXSkgPC0tPiBBZ2VudAogICAgc3ViZ3JhcGggQWdlbnRbQ29tcGxldGUgQWdlbnRdCiAgICAgICAgTG9vcFtBZ2VudCBMb29wXQogICAgICAgIHN1YmdyYXBoIFRvb2xzCiAgICAgICAgICAgIFJGW3JlYWRfZmlsZV0KICAgICAgICAgICAgTEZbbGlzdF9maWxlc10KICAgICAgICAgICAgRUZbZWRpdF9maWxlXQogICAgICAgIGVuZAogICAgICAgIExvb3AgPC0tPiBUb29scwogICAgZW5kCiAgICBUb29scyA8LS0-IEZTWyhGaWxlIFN5c3RlbSld)

## Agent Capabilities

| Capability | Tool | Example |
|-----------|------|---------|
| **Explore** | list_files | "What's in this project?" |
| **Understand** | read_file | "How does main.go work?" |
| **Modify** | edit_file | "Fix this bug" |

## The edit_file Tool

Uses search/replace for precise edits:

![edit_file](https://mermaid.ink/img/Zmxvd2NoYXJ0IExSCiAgICBzdWJncmFwaCBJbnB1dAogICAgICAgIEFbcGF0aDogZmlsZS5nb10KICAgICAgICBCW29sZF9zdHI6IHRleHQgdG8gZmluZF0KICAgICAgICBDW25ld19zdHI6IHJlcGxhY2VtZW50XQogICAgZW5kCiAgICBzdWJncmFwaCBCZWhhdmlvcgogICAgICAgIER7b2xkX3N0ciBlbXB0eT99CiAgICAgICAgRCAtLT58eWVzfCBFW0NyZWF0ZSBuZXcgZmlsZV0KICAgICAgICBEIC0tPnxub3wgRltSZXBsYWNlIHRleHRdCiAgICBlbmQKICAgIElucHV0IC0tPiBCZWhhdmlvcg)

## Example: Bug Fix Workflow

![Bug Fix](https://mermaid.ink/img/c2VxdWVuY2VEaWFncmFtCiAgICBwYXJ0aWNpcGFudCBVc2VyCiAgICBwYXJ0aWNpcGFudCBDbGF1ZGUKICAgIHBhcnRpY2lwYW50IFRvb2xzCiAgICBVc2VyLT4-Q2xhdWRlOiBGaXggdGhlIHR5cG8gaW4gbWFpbi5nbwogICAgQ2xhdWRlLT4-VG9vbHM6IGxpc3RfZmlsZXMgLgogICAgVG9vbHMtLT4-Q2xhdWRlOiBtYWluLmdvLCAuLi4KICAgIENsYXVkZS0-PlRvb2xzOiByZWFkX2ZpbGUgbWFpbi5nbwogICAgVG9vbHMtLT4-Q2xhdWRlOiBGaWxlIHdpdGggdHlwbwogICAgQ2xhdWRlLT4-VG9vbHM6IGVkaXRfZmlsZSBwYXRoIG9sZD10ZWggbmV3PXRoZQogICAgVG9vbHMtLT4-Q2xhdWRlOiBPSwogICAgQ2xhdWRlLT4-VXNlcjogRml4ZWQgdHlwbyB0ZWggdG8gdGhl)

## Run It

```bash
mise run go:step-05
```

Try asking:
- "Create a hello.txt file with a greeting"
- "Add a comment to main.go explaining what it does"
- "Find and fix any typos in the README"
