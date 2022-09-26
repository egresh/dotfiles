alias sk='vi ~/.skhdrc'

alias vi='nvim'
alias rvmon="export RVMP=true"
alias rvmoff="export RVMP="

alias -g W='| wc -l'
alias -g P='ps aux | grep -i '
alias -g G='| grep '
alias -g L='| less'

# Abbreviated commands on all hosts
_colorls=$(which colorls)
if [ -n $_colorls ]; then
    alias ls="colorls"
fi

_grep=$(which rg)
if [ -n $_grep ]; then
    alias grep="rg"
else
    alias grep="egrep"
fi

alias lc="colorls"
alias ll="colorls -l"
alias ltr="ls -ltr"
alias ltra='ls -ltra'
alias t='tree'
alias tl1='tree -L 1'
alias tl2='tree -L 2'
alias tl3='tree -L 3'
alias l='/bin/ls'
alias resource="source ~/.zshrc"
alias more="less -n"
alias aux='ps aux'
alias ef='ps -ef'
alias h='history'
alias be='bundle exec'
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'

# Spelling aliase
alias -g grpe=grep
alias -g gerp=grep
alias -g insall=install
alias gti='git'
alias get='git'

# Shortcuts for editing config files
alias nvimrc="nvim ~/.config/nvim/init.vim"
alias vimrc="vi ~/.vim/vimrc"
alias bashrc="nvim  ~/.bashrc"
alias zshrc="vi ~/.zshrc"
alias tmuxrc="vi ~/.tmux.conf"
alias yabairc="vi ~/.config/yabai/yabairc"

#Docker
alias dp="docker ps"
alias dpa="docker ps -a"
alias dpl="docker ps -l"
alias dpf="docker ps --format \
    '\nID\t{{.ID}}\nIMAGE\t{{.Image}}\nCOMMAND\t{{.Command}}\nCREATED\t{{.RunningFor}}\nSTATUS\t{{.Status}}\nPORTS\t{{.Ports}}\nNAMES\t{{.Names}}\n'"
alias dn="docker network"
alias di="docker images"
alias dc="docker commit"
alias db="dockr build"

#Kitchen
alias ks='kitchen status'
alias kl='kitchen login '
alias kc='kitchen converge '
alias kd='kitchen destroy '
alias kv='kitchen verify '
#
# Misc
alias e="nvr "
alias gst="git status"
alias fp="fzf --preview 'cat {}'"

alias gf='vi $(fasd -lf | fzf --tac)'
alias gd='cd $(fasd -ld | fzf --tac)'

# Rails
alias dbdev="sqlite3 -line db/development.sqlite3 "
alias dbtst="sqlite3 -line db/test.sqlite3 "
alias dbprd="sqlite3 -line db/production.sqlite3 "
