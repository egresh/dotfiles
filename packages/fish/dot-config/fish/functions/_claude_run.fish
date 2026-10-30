function _claude_run
    set -l model $argv[1]
    set -l effort high
    set -l rest

    if set -q argv[2]
        if contains -- $argv[2] low medium high xhigh max
            set effort $argv[2]
            set rest $argv[3..-1]
        else if string match -qr '^-' -- $argv[2]
            set rest $argv[2..-1]
        else
            echo "Invalid effort: $argv[2]. Use: low, medium, high, xhigh, max" >&2
            return 1
        end
    end

    # On Bedrock the bare `sonnet` alias resolves to Sonnet 4.5, so pin the
    # 5-series ids for anything that resolves aliases later (e.g. /model).
    set -lx ANTHROPIC_DEFAULT_SONNET_MODEL us.anthropic.claude-sonnet-5
    set -lx ANTHROPIC_DEFAULT_OPUS_MODEL us.anthropic.claude-opus-5

    claude --model $model --effort $effort $rest
end
