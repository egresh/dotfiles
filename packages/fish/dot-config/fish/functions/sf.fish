function sf -d "Select Tmux Session"
  sesh connect $(sesh list --icons | fzf --ansi)
end
