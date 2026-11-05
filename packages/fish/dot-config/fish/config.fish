# Add at the top
fish_add_path --move --path /opt/homebrew/bin /opt/homebrew/sbin

# Add at the bottom
fish_add_path --path --append $HOME/bin $HOME/.local/bin

set -x EDITOR $HOME/bin/sl
set -g fish_greeting

set -x LANG "en_US.UTF-8"
set -x LESS JeFXnimR

set -x FZF_DEFAULT_COMMAND "rg --files --no-ignore --hidden --follow"
set -x FZF_DEFAULT_OPTS "--tmux 50%,70%"
#set -x FZF_CTRL_T_OPTS "-d 30%"
#set -x FZF_CTRL_T_COMMAND "fzf-tmux"

set -x XDG_CONFIG_HOME $HOME/.config
set -x XDG_CACHE_HOME $HOME/.cache
set -x XDG_DATA_HOME $HOME/.local/share
set -x XDG_STATE_HOME $HOME/.local/state

set -x _FASD_DATA $HOME/.config/fasd/fasd_data_file
set -x GOKU_EDN_CONFIG_FILE $XDG_CONFIG_HOME/karabiner/karabiner.edn
set -x LUA_PATH "$HOME/dev/lua/?/init.lua;$HOME/dev/lua/?.lua;;"
set -x PSQL_PAGER 'pspg -X -b -s 19'
set -x PSQLRC $XDG_CONFIG_HOME/psql/psqlrc
set -x INPUTRC $XDG_CONFIG_HOME/readline/inputrc
set -x SSLKEYLOGFILE "$HOME/tmp/ssl_key_logfile"
set -x KITTY_CONFIG_DIRECTORY "$XDG_CONFIG_HOME/kitty"
set -x EZA_ICONS_AUTO TRUE
set -x RIPGREP_CONFIG_PATH ~/.config/ripgrep/ripgrep.conf
set -x STARSHIP_CONFIG $HOME/.config/starship/starship-fish.toml
set -x EZA_CONFIG_DIR ~/.config/eza
set -x TINTED_SHELL_ENABLE_BASE16_VARS 1
set -x TINTED_SHELL_ENABLE_BASE24_VARS 1

if status is-interactive
    fish_vi_key_bindings
    # fish_vi_key_bindings sets fish_key_bindings with `set --no-event`, so
    # plugin-bang-bang's --on-variable handler never fires. Re-run it here.
    functions -q _plugin-bang-bang_key_bindings; and _plugin-bang-bang_key_bindings

    alias wk "workmux"
    bind -M default \cp up-or-search
    bind -M default \cn down-or-search
    bind -M default \e\[1\;5B up-or-search
    bind -M default \e\[1\;5A down-or-search
    # bind -M insert \ci backward-delete-char
    bind -M insert \cp up-or-search
    bind -M insert \cn down-or-search
    bind -M insert \e\[1\;5B up-or-search
    bind -M insert \e\[1\;5A down-or-search
    bind -M insert --sets-mode default jk repaint
    bind -M default \cr history-pager
    bind -M insert \cr history-pager
    bind -M insert \cf nextd-or-forward-word
    bind -M insert \ce forward-char
    bind -M insert xq forward-char
    bind -M insert xw nextd-or-forward-word

    abbr -a .. cd ..
    abbr -a ... cd ../../
    abbr -a .... cd ../../../
    abbr -a ls eza
    abbr -a ll eza --git --long --show-symlinks
    abbr -a lt eza --icons --long --time=modified --sort=modified --show-symlinks
    abbr -a ltr eza --icons --long --time=modified --sort=modified --reverse --show-symlinks
    abbr -a llt eza --icons --long -t modified -s modified --tree
    abbr -a llt1 eza --icons --long -t modified -s modified --tree --level=1
    abbr -a llt2 eza --icons --long -t modified -s modified --tree --level=2
    abbr -a be bundle exec
    abbr -a lg lazygit
    abbr -a re rg
    abbr -a grep rg -uuuL
    abbr -a c container
    abbr -a wm workmux
    abbr -a --position command g git
    abbr -a --position command gti git
    abbr -a --position command get git
    abbr -a --position command gerp grep
    abbr -a --position command cat bat --paging=never
    abbr -a --position command nat bat --plain
    abbr -a --position anywhere G "| rg "
    abbr -a --position anywhere --set-cursor L "% | less"
    abbr -a --position anywhere W "| wc -l"
    abbr -a --position command P "ps aux | rg "
    abbr -a --position anywhere O "| peco"
    abbr -a --position anywhere H "| head "
    abbr -a --position anywhere T "| tail -f "
    abbr -a --position anywhere B "| bat --paging=never -l log"
    abbr -a --position command k kubecolor
    abbr -a --position command kx kubectx

    abbr -a --position command dc docker-compose
    abbr -a --position command dcb "COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose build"
    abbr -a --position command dcu "docker compose up -d"
    abbr -a --position command dcl "docker-compose logs -f"
    abbr -a --position command dcredo "docker compose up -d --no-deps --build"
    abbr -a --position command dcr "docker-compose run --rm"
    abbr -a --position command dcp "docker-compose ps"
    abbr -a --position command dce "docker-compose exec"
    abbr -a --position command dp "docker ps"
    abbr -a --position command dpa "docker ps -a"
    abbr -a --position command dpl "docker ps -l"
    # abbr -a --position command "docker ps --format \
    #     \nID\t{{.ID}}\nIMAGE\t{{.Image}}\nCOMMAND\t{{.Command}}\nCREATED\t{{.RunningFor}}\nSTATUS\t{{.Status}}\nPORTS\t{{.Ports}}\nNAMES\t{{.Names}}\n"
    abbr -a --position command dk "docker kill"
    abbr -a --position command dn "docker network"
    abbr -a --position command di "docker images"
    abbr -a --position command dc "docker commit"
    abbr -a --position command db "docker build"
    abbr -a --position command dbl "docker build"
    abbr -a --position command dpu "docker pull"
    abbr -a --position command dtop "docker top"
    abbr -a --position command dcin "docker container inspect"
    abbr -a --position command dlo "docker container logs"
    abbr -a --position command dcls "docker container ls"
    abbr -a --position command dclsa "docker container ls -a"
    abbr -a --position command dpo "docker container port"
    abbr -a --position command dr "docker container run"
    abbr -a --position command drit "docker container run -it"
    abbr -a --position command drm "docker container rm"
    abbr -a --position command drm! "docker container rm -f"
    abbr -a --position command dst "docker container start"
    abbr -a --position command dstp "docker container stop"
    abbr -a --position command dxc "docker container exec"
    abbr -a --position command dxcit "docker container exec -it"
    abbr -a --position command dib "docker image build"
    abbr -a --position command dii "docker image inspect"
    abbr -a --position command dils "docker image ls"
    abbr -a --position command dipu "docker image push"
    abbr -a --position command dirm "docker image rm"
    abbr -a --position command dit "docker image tag"
    abbr -a --position command dnc "docker network create"
    abbr -a --position command dncn "docker network connect"
    abbr -a --position command dndcn "docker network disconnect"
    abbr -a --position command dni "docker network inspect"
    abbr -a --position command dnls "docker network ls"
    abbr -a --position command dnrm "docker network rm"
    abbr -a --position command dvi "docker volume inspect"
    abbr -a --position command dvls "docker volume ls"
    abbr -a --position command dvprune "docker volume prune"

    abbr -a efish "~/bin/sl ~/.config/fish/config.fish"
    abbr -a ekara "~/bin/sl ~/.config/karabiner/karabiner.edn"
    abbr -a emux "~/bin/sl ~/.config/tmux/tmux.conf"
    abbr -a esl "~/bin/sl ~/.config/lazyvim/lua"
    abbr -a esesh "~/bin/sl ~/.config/sesh/sesh.toml"
    abbr -a emise "~/bin/sl -O ~/.config/mise/config.toml ~/.config/mise/miserc.toml"

    abbr -a opencode "OTUI_USE_ALTERNATE_SCREEN=false opencode"
    abbr -a conf "sesh connect (sesh list | gum filter --limit 1 --placeholder 'Pick a sesh' --prompt='')"

    abbr -a max "blueutil --connect 70-F9-4A-9C-49-0F"
end

zoxide init fish         | source
starship init fish       | source
fzf --fish               | source
carapace _carapace       | source

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/egresh/.lmstudio/bin
# End of LM Studio CLI section
