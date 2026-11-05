# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A macOS dotfiles repo managed with GNU Stow. Configs are organized so that `stow` can symlink them into their proper locations.

## How stow is used

**`xdg_config/`** — configs that land in `~/.config/`. Contains a `.stowrc` targeting `~/.config`; run `stow -S *` from inside to stow everything, or stow individual subdirs.

**`custom_stowrc/`** — configs with non-standard targets (bin, hammerspoon, tmux). Each subdir has a `*_readme.txt` with the exact stow command and any prerequisites.

**`root_config/`** — configs that land in `~/` (zsh, inputrc, psql).

**`fish/`** — fish shell config, stowed to `~/.config/fish`.

## Neovim environments

Multiple Neovim configs coexist via `NVIM_APPNAME`:

| Command | `NVIM_APPNAME` | Config dir |
|---------|----------------|------------|
| `nvim` | (default) | `~/.config/lazyvim` |
| `evim` (bin/evim) | `lazyvim` | Opens a file picker via fzf inside `~/.config/lazyvim` |
| `st` (bin/st) | `lazyvim_test` | Test/scratch environment |
| `sk` (bin/sk) | `kickstart.nvim` | Kickstart config |

Active environments are listed in `neovim_environments`.

The main config is in `xdg_config/lazyvim/lazyvim/`. `lazyvim_clean/` is a stripped-down copy of the same LazyVim base. Both share the same plugin structure under `lua/plugins/`.

## Key configs by tool

- **Fish**: `fish/config.fish` — paths, env vars, vi bindings, abbreviations; uses starship, zoxide, direnv, fzf, thefuck, asdf
- **Window manager — OmniWM (primary)**: OmniWM is the active tiling WM going forward. Its config lives at `~/.config/omniwm/settings.toml` (outside this repo — GUI-managed and live-reloaded), and it's driven via the `omniwmctl` CLI. Karabiner leader keys control it (`:omni` template → `omniwmctl command`).
- **AeroSpace (legacy/deprecated)**: `xdg_config/aerospace/aerospace/aerospace.toml` — the previous tiling WM; launches sketchybar and JankyBorders on startup. Retained only as a fallback; no longer primary and not actively maintained. The sketchybar config still has an auto-detected AeroSpace backend (`wm/aerospace/`) for this reason.
- **Sketchybar**: `xdg_config/sketchybar/sketchybar/sketchybarrc` — Lua-based bar config using SbarLua
- **Kitty**: `xdg_config/kitty/kitty/kitty.conf` — multiple named themes (Dracula, Gruvbox, ENCOM)
- **WezTerm**: `xdg_config/wezterm/wezterm/wezterm.lua`
- **Karabiner**: `xdg_config/karabiner/karabiner/` — uses Goku/EDN format (`karabiner.edn`)
- **Hammerspoon**: `custom_stowrc/hammerspoon/` — requires stackline cloned to `~/.config/hammerspoon/stackline`, and `defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"`
- **tmux**: `xdg_config/tmux/tmux.conf` and `custom_stowrc/tmux/tmux.conf` — TPM for plugins

## Lua utilities (bin/summon)

`lua/` contains shared Lua modules used by `bin/summon` and the AeroSpace scripts:
- `lua/aerospace/` — AeroSpace CLI wrapper
- `lua/commands/`, `lua/utils/` — helpers for workspace management and running app instances
