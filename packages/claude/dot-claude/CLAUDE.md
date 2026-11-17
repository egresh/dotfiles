# Shell

I use the **fish shell** (`/opt/homebrew/bin/fish`), not bash/zsh. When running or suggesting shell commands, use fish-compatible syntax. Key differences to watch for:

- Env vars: `set -x VAR value` (not `export VAR=value`)
- Command substitution: `(cmd)` (not `$(cmd)` — that works too, but backticks do not)
- No `&&`/`||` chaining differences, but `; and`/`; or` is the fish idiom
- No `~/.bashrc` — config lives in `~/.config/fish/config.fish`
- Conditionals/loops use fish syntax (`if test ...; end`, `for x in ...; end`)

# Git

Git worktree management should use the workmux tool.

# Stow

This project uses Stow to manage packages.

## `ls`

I alias `ls` to **eza**, which takes different flags than coreutils `ls`. When you need a directory listing, use plain generic `ls` with portable flags (or invoke `command ls`) — don't assume eza-specific options.
# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, use the installed graphify skill or instructions before doing anything else.

# Personal preferences

- Keep responses concise.
- Don't add dependencies without asking.
- Don't explain routine changes unless requested.
