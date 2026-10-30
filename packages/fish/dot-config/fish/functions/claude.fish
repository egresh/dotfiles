function claude
    if type -q aws
        if not aws sts get-caller-identity --profile claude-code >/dev/null 2>&1
            aws sso login --profile claude-code
        end
    end

    set -l shared "$HOME/.claude/settings.shared.json"
    set -l machine "$HOME/.claude/settings.machine.json"

    if not test -f $shared
        command claude $argv
        return
    end

    set -l merged (mktemp)
    if test -f $machine
        jq -s '.[0] * .[1]' $shared $machine >$merged
    else
        cp $shared $merged
    end

    command claude --settings $merged $argv
    set -l code $status
    rm -f $merged
    return $code
end
