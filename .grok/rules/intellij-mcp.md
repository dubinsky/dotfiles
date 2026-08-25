# IntelliJ MCP: PSI over grep for symbols

Leonid’s IntelliJ (2025.2+) exposes an MCP server named `intellij` to Grok (`~/.grok/config.toml`). Use it for **semantic** code work in any language the IDE indexes (Scala, Java, Kotlin, JS/TS, …). Text search stays for comments, strings, docs, and config.

Grok does **not** get these tools unless it calls `search_tool` then `use_tool`. Prefer them without being asked.

## Before semantic work

Need the IDE **running** with **this project open**.

1. If `search_tool` does not list `intellij` tools: the MCP proxy is down. Ask him to **start IntelliJ**, **File → Open** the repo (the cwd / git root), and confirm **Settings → Tools → MCP Server** is enabled. Do not invent a port or start a second IDE. After he says it is up, retry `search_tool`. If this Grok session started before the server was added, ask him to **restart Grok**.
2. If `intellij` tools exist, call `intellij__get_project_modules` or `intellij__get_all_open_file_paths` with `projectPath` = the repo root. Wrong project, empty result, or an error about no project → ask him to **open this repo** in that IntelliJ window, then retry.
3. Always pass `projectPath` (repo root, or cwd if that is all you know).

Do not proceed with a PSI rename, find-usages, or inspection pass while the IDE is down or on another project. File edits that do not need PSI may continue.

## Use IntelliJ for

Discover exact names with `search_tool` (`query`: `intellij …`). Typical tools:

| Job | Tool (qualified names vary; search first) |
|---|---|
| Rename a symbol (methods, classes, vals, including overloads / extensions / givens) | `intellij__rename_refactoring` |
| Find a symbol by name | `intellij__search_symbol` |
| Callers / callees | `intellij__analyze_calls` (`INCOMING_CALLS` / `OUTGOING_CALLS`) after you have a FQN |
| Quick doc / declaration at a position | `intellij__get_symbol_info` |
| Inspections after edits | `intellij__get_file_problems` / `intellij__lint_files` |

Do **not** grep-and-replace a programmatic identifier when `rename_refactoring` can see it.

## Keep grep / file edits for

- Comments, string literals, Markdown, YAML, CSS
- New code, new files, mechanical copies
- Repos IntelliJ cannot index, or after he declines to open the IDE

Config: stdio `idea stdioMcpServer` with `IJ_MCP_SERVER_PORT` (often `64342`, not the `63342` built-in web server). If `grok mcp doctor intellij` fails after an IDE restart, ask him for **Settings → Tools → MCP Server → Copy Stdio Config** and update the port. Do not enable “brave mode” unless he asks.
