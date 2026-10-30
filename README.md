# dots

One stow package per tool under `packages/`, each mirroring its path under `~`.

    stow fish        # link a package (run from the repo root; .stowrc sets dir, target, --no-folding, --dotfiles)
    stow -D fish     # unlink

`--no-folding` keeps directories real, so files a tool writes next to your config
(fisher plugins, generated completions) stay out of the repo.
