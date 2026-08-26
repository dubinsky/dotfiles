# Playwright MCP: clean snapshot files

After using Playwright in a project workspace, delete leftover snapshot files before ending the turn. The MCP writes them under `.playwright-mcp/` (and sometimes the project root):

- `page-*.yml` / `page-*.yaml` (accessibility snapshots)
- screenshots you saved into the repo (`browser_take_screenshot` without a path still lands in cwd)

Do not leave these as untracked files. Console logs in `.playwright-mcp/` from the same session can go too; do not delete older logs you did not create.

Do not `git add` `.playwright-mcp/`.
