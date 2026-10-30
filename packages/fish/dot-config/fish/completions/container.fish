# ~/.config/fish/completions/container.fish

# Define the list of subcommands
set -l subcommands 'attach detach list info'

# Provide completions for the subcommands
complete -c container -a "$subcommands"

# Provide completions for the 'attach' subcommand
complete -c container -n "__fish_seen_subcommand_from attach" -a "--help --verbose"

# Provide completions for the 'detach' subcommand
complete -c container -n "__fish_seen_subcommand_from detach" -a "--help --verbose"

# Provide completions for the 'list' subcommand
complete -c container -n "__fish_seen_subcommand_from list" -a "--help --verbose"

# Provide completions for the 'info' subcommand
complete -c container -n "__fish_seen_subcommand_from info" -a "--help --verbose"
