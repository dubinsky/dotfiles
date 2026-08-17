# Dotfiles are yadm, not a home-directory Git repo

Leonid manages selected files under `$HOME` with [yadm](https://yadm.io/) (v3). There is **no** `~/.git`. `git -C "$HOME"` and “is `$HOME` a git repo?” will fail; do not `git init` there.

| What | Where |
|---|---|
| Git directory | `~/.local/share/yadm/repo.git` |
| Work tree | `$HOME` (`/home/dub`) |
| Remote `origin` | `git@github.com:dubinsky/dotfiles.git` |
| Branch | `master` |
| Bootstrap | `~/.config/yadm/bootstrap` (runs `bootstrap.d/*`) |
| Human notes | `~/Podval/dub.podval.org/notes/SystemAdministration/dotfiles.md` |

Use `yadm` as the git wrapper (`yadm status`, `yadm add`, `yadm commit`, `yadm ls-files`, `yadm log`). Equivalent raw git:

```bash
git --git-dir="$HOME/.local/share/yadm/repo.git" --work-tree="$HOME" …
```

## Traps (do not rediscover)

- Only a small explicit set is tracked (~60–70 files: shell, Hypr/Omarchy, yadm bootstrap, a few `.grok/skills`, rclone helpers). `$HOME` is **not** a monorepo. Do not `yadm add` a whole tree.
- `status.showUntrackedFiles = no`, so `yadm status` hides untracked files. Use `yadm ls-files` to see what is in the repo.
- `git ls-tree HEAD` without `--full-tree` is cwd-relative and looks empty from a subdirectory. Prefer `yadm ls-files` or `git ls-tree -r --full-tree HEAD`.
- Never track secrets in plaintext. Traveling secrets go through `yadm encrypt` (see below). `.zotero/**/prefs.js` is in the repo exclude (API keys leaked there once).
- `yadm` does not overwrite pre-existing files on clone; use `yadm checkout <file>` to force.

## Secrets archive

Patterns: `~/.config/yadm/encrypt`. Ciphertext: `~/.local/share/yadm/archive` (tracked). Recipient: YubiKey OpenPGP `049DC4EF6FB97468` (`yadm.gpg-recipient`). Public key: `~/.config/yadm/yubikey-openpgp.asc`. Private material is **only** on the 5C (serial 18600387); decrypt needs the card, User PIN, and a touch (`uif` decrypt=on). Encrypt uses the public key (no tap).

After changing a secret: `yadm encrypt && yadm add ~/.local/share/yadm/archive && yadm commit`. On a new machine: import the `.asc` (bootstrap does this), `yadm decrypt`. Do not `yadm add` the matched plaintext files.

When changing a tracked dotfile, commit with `yadm`, not with a project repo in a subdirectory.
