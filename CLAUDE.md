# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

macOS dotfiles managed with GNU Stow. See `README.md` for the short version.

## Git

Any changes should be checked out into a new git worktree. Workmux is used to manage worktrees.

## Layout

- **`packages/<tool>/`** — one stow package per tool, each mirroring its path under `~`. `.stowrc` (repo root) sets `--dir=packages --target=$HOME --no-folding --dotfiles`, so run `stow <pkg>` / `stow -D <pkg>` from the repo root. `--dotfiles` means `dot-config/` → `~/.config/`, `dot-claude/` → `~/.claude/`, etc. `--no-folding` keeps directories real, so tool-generated files stay out of the repo.
- **`dirlinks/`** — karabiner and sketchybar. These watch their own directory, so instead of stow, `bootstrap.sh` makes one symlink per directory at `~/.config/<name>`.
- **`mods/reprint/`** — a Claude Code mod (TypeScript hooks). Linked as a whole directory to `~/.claude/mods/reprint` by `bootstrap.sh` (Claude Code rejects hooks reached via per-file symlinks); loaded via `CLAUDE_CODE_PLUGIN_DIRS` in `packages/claude/dot-claude/settings.json`. Don't stow it.
- **`Brewfile`** — everything installed via Homebrew.

## Scripts

- **`./bootstrap.sh`** — new-machine setup, safe to re-run: `brew bundle`, stows every package, makes the dirlinks and mod link, installs SbarLua and builds the sketchybar helpers, sets `defaults` (Hammerspoon config path, Tinycast hotkey), `mise install`, fisher plugins, generated fish completions (sesh, tinty, omniwmctl), TPM plugins, and a first tinty theme.
- **`./test.sh`** — hermetic: stows every package into a temp HOME and checks every file is a correct symlink, nothing is broken, and no tracked file is gitignored. Then runs `tests/<pkg>.sh $sandbox_home` if it exists (currently `fish`, `nvim-refs`, `tinted-theming`). Run this after adding/moving files in a package.
- **`./verify.sh`** — checks the *real* HOME after bootstrap (Brewfile, mise, fisher plugins, completions, TPM, tinty theme, dirlinks, Claude settings symlink, reprint mod, sketchybar helpers).

When adding a package, add any non-stow setup step to `bootstrap.sh` and a matching check to `verify.sh`. Tool-generated or machine-local files belong in `.gitignore`, not the repo.

## Theming (tinty)

`packages/tinted-theming/` configures tinty (base16/base24). The fish `tinty` wrapper (`functions/tinty.fish`) runs `hooks/apply-extras.rb` after `apply`/`cycle`, which propagates the scheme to things tinty can't theme natively: sketchybar (`tinty_palette.lua`), OmniWM `settings.toml` (rewrites colours in place), nushell, workmux, and Claude Code (`~/.claude/themes/tinty.json`, `~/.claude/statusline-colors.env`). It must write *through* stowed symlinks, not replace them (covered by `tests/tinted-theming.sh`).

## Claude Code (`packages/claude`)

Links `CLAUDE.md`, `settings.json`, `statusline-command.sh` and `agents/` into `~/.claude`, which stays a real directory. Claude Code writes `settings.json` through the symlink, so `/model`, `/config` and plugin installs show up as repo diffs — commit what's worth keeping. Machine-specific env vars go in the untracked fish `conf.d/local.fish`. Details in `claude_readme.txt`.

## Neovim

Only the LazyVim config is tracked: `packages/lazyvim/dot-config/lazyvim/` (plugins in `lua/plugins/`). Launchers in `packages/bin/bin/` set `NVIM_APPNAME`:

| Command | `NVIM_APPNAME` |
|---------|----------------|
| `sl` | `lazyvim` (tracked config) |
| `evim` | `lazyvim` — fzf picker over the config's Lua files |
| `sc` | `lazyvim_clean` |
| `st` | `lazyvim_test` |
| `sk` | `kickstart.nvim` |

`bin/nvim-refs` (tmux + fzf) opens `path:line` refs from a pane (e.g. Claude's output) in that worktree's nvim; its socket naming must match `lua/config/autocmds.lua`.

## Key configs by tool

- **Fish** (primary shell): `packages/fish/dot-config/fish/config.fish` — mise, zoxide, starship, fzf, carapace. Plugins via fisher (`fish_plugins`); `fish_variables`, `conf.d/` and generated completions are gitignored.
- **Nushell**: `packages/nushell/`.
- **OmniWM** (tiling WM): `packages/omniwm/dot-config/omniwm/settings.toml` — also edited by the OmniWM GUI and by tinty's hook, so expect diffs. Driven via `omniwmctl`; Karabiner leader keys call it (`:omni` template).
- **Sketchybar**: `dirlinks/sketchybar/` — Lua (SbarLua); WM backend in `wm/omniwm/`; C helpers built via `helpers/makefile` (binaries gitignored).
- **Karabiner**: `dirlinks/karabiner/karabiner.edn` (Goku) generates `karabiner.json`.
- **Terminals**: `packages/kitty/`, `packages/wezterm/`.
- **tmux**: `packages/tmux/dot-config/tmux/tmux.conf` — TPM plugins; sessions via `sesh`, worktrees via `workmux`.
- **Hammerspoon**: `packages/hammerspoon/dot-config/hammerspoon/` (bootstrap points Hammerspoon at it).
- **Git / SSH**: `packages/git/`, `packages/ssh/` — commit signing and GitHub keys via 1Password SSH agent.
- **Runtimes**: `packages/mise/`.
- Others: `inputrc`, `pry`, `psql`, `ripgrep`, `sqlite3`, `starship`.
