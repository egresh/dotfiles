# ZSH will always read /etc/zshrc unless started with -f.
# On OSX, this starts /usr/libexec/path_helper that reads
# /etc/paths and /etc/paths.d/* to construct the default
# path. This becomes problematic as path_helper is called
# on every shell invocation and manipulates the expected
# path order. PATH is addressed in startup scripts.
export LANG=en_US.UTF-8
export EDITOR=nvim

# -R = output raw characters for colors (piping special characters works)
# -e = exit after 2nd eof ( i.e. G followed by space )
# -X = don't send termcap init sequences ( prevent clearing screen )
# -F = Don't paginate if output fits on one screen
# -n = Don't display line numbers
# -i = Smart case searching
# -m = show percentage of file rather than : at the bottom
# -J = put an asterisk in the left column where a pattern is found
export LESS="JeFXnimR"

export HOMEBREW_GITHUB_API_TOKEN=`cat ~/.ssh/homebrew_token`
#deprecated
#export HOMEBREW_BUILD_FROM_SOURCE=true

#Moved casks from ~/Applications to /Applications
#export HOMEBREW_CASK_OPTS='--appdir=~/Applications'

# Used by browsers and wireshark to dump unencrypted SSL sessions
export SSLKEYLOGFILE=~/tmp/sslkeylog.txt

export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow'
export FZF_TMUX=1

export SOLARGRAPH_CACHE="$HOME/.config/solarcache"

export ZSH_AUTOSUGGEST_USE_ASYNC=true
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#000000,bg=white,bold,underline"
export HISTSIZE=20000
export SAVEHIST=50000
export WORDCHARS='~!#$%^&*(){}[]<>?.+;-'

# If $VIM is set, the shell is a Neovim terminal session. Unset these or else
# they get inherited by the terminal from Neovim and change were programs
# look for configuration data.
if [ -n "$VIM" ]; then
  unset XDG_CONFIG_HOME
  unset XDG_CACHE_HOME
  unset XDG_DATA_HOME
fi

export GOKU_EDN_CONFIG_FILE="${HOME}/.config/karabiner/karabiner.edn"
export LUA_PATH="$HOME/dev/lua/?/init.lua;$HOME/dev/lua/*/?.lua;$HOME/dev/lua/?.lua"
