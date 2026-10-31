# env.nu
#
# Installed by:
# version = "0.105.1"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.
print (ansi magenta) "Loading env.nu..."

use std/util "path add"
path add /opt/homebrew/bin /opt/homebrew/sbin
path add --append ($env.HOME | path join bin) ($env.HOME | path join .local/bin) ($env.HOME | path join .lmstudio/bin)

$env.XDG_CONFIG_HOME = $env.HOME | path join .config
$env.XDG_CACHE_HOME = $env.HOME | path join .cache
$env.XDG_DATA_HOME = $env.HOME | path join .local/share
$env.XDG_STATE_HOME = $env.HOME | path join .local/state

load-env {
  EDITOR: ($env.HOME | path join bin/sl)
  LANG: "en_US.UTF-8"
  LESS: "JeFXnimR"
  FZF_DEFAULT_COMMAND: "rg --files --no-ignore --hidden --follow"
  FZF_DEFAULT_OPTS: "--tmux 50%,70%"
  _FASD_DATA: ($env.XDG_CONFIG_HOME | path join fasd/fasd_data_file)
  GOKU_EDN_CONFIG_FILE: ($env.XDG_CONFIG_HOME | path join karabiner/karabiner.edn)
  LUA_PATH: $"($env.HOME)/dev/lua/?/init.lua;($env.HOME)/dev/lua/?.lua;;"
  PSQL_PAGER: "pspg -X -b -s 19"
  PSQLRC: ($env.XDG_CONFIG_HOME | path join psql/psqlrc)
  INPUTRC: ($env.XDG_CONFIG_HOME | path join readline/inputrc)
  SSLKEYLOGFILE: ($env.HOME | path join tmp/ssl_key_logfile)
  KITTY_CONFIG_DIRECTORY: ($env.XDG_CONFIG_HOME | path join kitty)
  EZA_ICONS_AUTO: "TRUE"
  EZA_CONFIG_DIR: ($env.XDG_CONFIG_HOME | path join eza)
  RIPGREP_CONFIG_PATH: ($env.XDG_CONFIG_HOME | path join ripgrep/ripgrep.conf)
  TINTED_SHELL_ENABLE_BASE16_VARS: "1"
  TINTED_SHELL_ENABLE_BASE24_VARS: "1"
}
