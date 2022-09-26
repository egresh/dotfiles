# Time to wait for a key sequence to complete when in zle in
# hundredths of a second. If too long, there's problems when
# hitting escape. If too short, commands like 'kk' can't complete.
export KEYTIMEOUT=50

unsetopt correct
unsetopt histverify
setopt   extended_history
setopt   hist_find_no_dups
setopt   hist_ignore_dups
setopt   hist_expire_dups_first
setopt   hist_ignore_space
setopt   hist_reduce_blanks
setopt   hist_ignore_space
setopt   share_history
setopt   autopushd
setopt   nocaseglob
setopt   auto_cd

zle -N edit-command-line
zle -N fancy-ctrl-z

autoload -Uz edit-command-line
autoload -Uz compinit
compinit

# ^ = Control, \e = ALT
bindkey -v
bindkey '^R' history-incremental-search-backward
bindkey '^p' up-history
bindkey '^n' down-history
bindkey '^W' backward-kill-word
bindkey '^U' backward-kill-line
bindkey '^?' backward-delete-char
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line
bindkey '^Z' fancy-ctrl-z
bindkey -r '^T'
bindkey '^F' fzf-file-widget

bindkey -M vicmd 'v' edit-command-line
bindkey -M vicmd '=' up-line-or-history
bindkey -M viins 'jk' vi-cmd-mode
bindkey -M viins 'xq' autosuggest-accept
bindkey -M viins 'xw' forward-word
# bindkey -M viins '^[[C' vi-forward-word
# bindkey -M viins 'fc' autosuggest-clear
bindkey -M viins '^g' backward-delete-char

bindkey -s '^[OA' '['
bindkey -s '^[[1;2A' '{'
bindkey -s '^[OB' ']'
bindkey -s '^[[1;2B' '}'

# Ensure that the prompt is redrawn when the terminal size changes.
TRAPWINCH() {
  zle &&  zle -R
}

# ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(${ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS[@]} vi-forward-word)

# autosuggest-accept: Accepts the current suggestion.
# autosuggest-execute: Accepts and executes the current suggestion.
# autosuggest-clear: Clears the current suggestion.
# autosuggest-fetch: Fetches a suggestion (works even when suggestions are disabled).
# autosuggest-disable: Disables suggestions.
# autosuggest-enable: Re-enables suggestions.
# autosuggest-toggle: Toggles between enabled/disabled suggestions.

