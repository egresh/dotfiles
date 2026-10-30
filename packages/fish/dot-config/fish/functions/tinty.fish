function tinty --wraps tinty --description 'tinty + resync sketchybar/OmniWM/nushell colours'
    command tinty $argv
    set -l rc $status

    # Only subcommands that change the active scheme need a resync, and only
    # when tinty succeeded (a failed cycle leaves the scheme unchanged).
    if test $rc -eq 0; and contains -- "$argv[1]" apply cycle
        # Stable ~/.config path: it resolves whichever repo stows tinted-theming.
        # (A path relative to $__fish_config_dir broke once ~/.config/fish became
        # per-file symlinks into another repo, and the hook silently stopped running.)
        set -l hook ~/.config/tinted-theming/tinty/hooks/apply-extras.rb
        if test -f "$hook"
            ruby "$hook"
        else
            echo "tinty: resync hook not found: $hook" >&2
        end
    end

    return $rc
end
