packages/claude links a few tracked files into ~/.claude, which stays a real
directory at Claude Code's default location: it also holds transcripts, history,
plugins and login state, none of which belong in this repo.

settings.json is the only settings file. Claude Code writes to it (/model,
/config, plugin installs), and those writes go through the symlink, so they show
up as repo diffs: commit what you want to keep. If it ever stops being a symlink,
./verify.sh fails. For something one machine needs, put env vars in the untracked
fish conf.d/local.fish.

mods/reprint (repo root, not in the package) is loaded through
CLAUDE_CODE_PLUGIN_DIRS in settings.json, via one symlink to the whole directory
at ~/.claude/mods/reprint that bootstrap.sh makes. Don't stow it: Claude Code
refuses hooks reached through per-file symlinks ("Path escapes plugin directory").
The TypeScript types it generates in .claude-plugin/types are gitignored.

The theme (custom:tinty) and status line colours come from two untracked files
that tinty's apply-extras.rb generates: ~/.claude/themes/tinty.json and
~/.claude/statusline-colors.env.
