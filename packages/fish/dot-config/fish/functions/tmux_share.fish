function tmux_share
tmux new-session -t $(tmux list-sessions | fzf --border --height=10 | cut -d: -f1) -s shared
end
