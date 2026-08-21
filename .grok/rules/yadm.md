# Dotfiles are yadm, not a home-directory Git repo

Leonid manages selected files under `$HOME` with [yadm](https://yadm.io/) (v3). There is **no** `~/.git`. `git -C "$HOME"` and “is `$HOME` a git repo?” will fail; do not `git init` there.

Layout, bootstrap, and `yadm encrypt` (including the OpenPGP recipient): `~/Podval/dub.podval.org/notes/SystemAdministration/dotfiles.md`.

Use `yadm` as the git wrapper (`yadm status`, `yadm add`, `yadm commit`, `yadm ls-files`, `yadm log`). Equivalent raw git:

```bash
git --git-dir="$HOME/.local/share/yadm/repo.git" --work-tree="$HOME" …
```

## Traps (do not rediscover)

- `$HOME` is **not** a monorepo. Do not `yadm add` a whole tree.
- `yadm status` hides untracked files (`status.showUntrackedFiles = no`). Use `yadm ls-files` to see what is in the repo.
- `git ls-tree HEAD` without `--full-tree` is cwd-relative and looks empty from a subdirectory. Prefer `yadm ls-files` or `git ls-tree -r --full-tree HEAD`.
- Never track secrets in plaintext. Traveling secrets go through `yadm encrypt`. After changing a secret: `yadm encrypt && yadm add ~/.local/share/yadm/archive && yadm commit`. Do not `yadm add` the matched plaintext files.
- When changing a tracked dotfile, commit with `yadm`, not with a project repo in a subdirectory.
