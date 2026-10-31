def sc [...args] {
    with-env { NVIM_APPNAME: "lazyvim_clean" } { nvim ...$args }
}

def sl [...args] {
    with-env { NVIM_APPNAME: "lazyvim" } { nvim ...$args }
}

# tinty + resync sketchybar/OmniWM/nushell colours
@complete external
def --wrapped tinty [...args] {
    ^tinty ...$args
    if ($args.0? in [apply cycle]) {
        ^ruby ~/.config/tinted-theming/tinty/hooks/apply-extras.rb
    }
}

def tmux_share [] {
    tmux new-session -t (tmux list-sessions | fzf --border --height=10 | cut -d: -f1 | str trim) -s shared
}

def tt [level: int = 1] {
    eza --tree --git $"--level=($level)"
}

# Select tmux session
def sf [] {
    sesh connect (sesh list --icons | fzf --ansi | str trim)
}

def dcd [...services] {
    if ($services | is-empty) {
        docker-compose down --remove-orphans
    } else {
        docker-compose stop ...$services
        docker-compose rm ...$services
    }
}

# down and back up
def dcdu [...services] {
    if ($services | is-empty) { print "usage: dcdu service-name …"; return }
    mutagen-compose stop ...$services
    mutagen-compose rm -f ...$services
    mutagen-compose up -d ...$services
}

def mcd [...services] {
    if ($services | is-empty) {
        mutagen-compose down --remove-orphans
    } else {
        mutagen-compose stop ...$services
        mutagen-compose rm -f ...$services
    }
}
alias srr = mcd

# kubectl -n test get pods, filtered
def ktgp [pattern: string] {
    kubectl -n test get pods | ^grep -i $pattern
}

def ef [query?: string] {
    let q = if $query == null { [] } else { [-q $query] }
    let file = try {
        fasd -Rfl | fzf ...$q --border --margin 5% --preview 'bat --color always {}' | str trim
    } catch { "" }
    if $file != "" { run-external $env.EDITOR $file }
}

# decode JWT
def jwt_decode [file: path] {
    open --raw $file | jq -R 'split(".") | .[] | @base64d | fromjson'
}

# restart yabai
def yr [] {
    yabai --stop-service
    yabai --start-service
}

@complete external
def --wrapped claude [...args] {
    if (which aws | is-not-empty) {
        if (do { ^aws sts get-caller-identity --profile claude-code } | complete).exit_code != 0 {
            ^aws sso login --profile claude-code
        }
    }

    let shared = $env.HOME | path join .claude/settings.shared.json
    let machine = $env.HOME | path join .claude/settings.machine.json
    if not ($shared | path exists) { ^claude ...$args; return }

    let merged = mktemp -t
    if ($machine | path exists) {
        ^jq -s '.[0] * .[1]' $shared $machine | save -f $merged
    } else {
        cp $shared $merged
    }
    try { ^claude --settings $merged ...$args } finally { rm -f $merged }
}
