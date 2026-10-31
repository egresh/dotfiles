# config.nu
#
# Installed by:
# version = "0.105.1"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.
# mkdir ~/.cache/carapace
print (ansi green) "Loading config.nu..."

# Initialization stuffs
# carapace _carapace nushell | save -f ~/.config/nushell/autoload/carapace.nu
# starship init nu           | save -f ~/.config/nushell/autoload/starship.nu
# zoxide init nushell        | save -f ~/.config/nushell/autoload/zoxide.nu

$env.STARSHIP_CONFIG = $env.HOME + "/.config/starship/starship-nushell.toml"
$env.PROMPT_INDICATOR_VI_INSERT = "❯ "
$env.PROMPT_INDICATOR_VI_NORMAL = " "

$env.config = {
  buffer_editor: "sl",
  edit_mode: "vi",
  show_banner: false,
  cursor_shape: {
    vi_insert: underscore,
    vi_normal: block,
    emacs: line
  }
}

# Ported from fish abbrs. Nushell only expands these at command position;
# fish's "anywhere" abbrs (G, W, H, ...) are pipe aliases in autoload/aliases.nu.
$env.config.abbreviations = {
  "..": "cd .."
  "...": "cd ../../"
  "....": "cd ../../../"
  ll: "eza --git --long --show-symlinks"
  lt: "eza --icons --long --time=modified --sort=modified --show-symlinks"
  ltr: "eza --icons --long --time=modified --sort=modified --reverse --show-symlinks"
  llt: "eza --icons --long -t modified -s modified --tree"
  llt1: "eza --icons --long -t modified -s modified --tree --level=1"
  llt2: "eza --icons --long -t modified -s modified --tree --level=2"
  be: "bundle exec"
  lg: "lazygit"
  re: "rg"
  grep: "rg -uuuL"
  c: "container"
  g: "git"
  gti: "git"
  gerp: "grep"
  cat: "bat --paging=never"
  nat: "bat --plain"
  P: "^ps aux | rg"
  k: "kubecolor"
  kx: "kubectx"
  wk: "workmux"

  dcb: "COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose build"
  dcu: "docker compose up -d"
  dcl: "docker-compose logs -f"
  dcredo: "docker compose up -d --no-deps --build"
  dcr: "docker-compose run --rm"
  dcp: "docker-compose ps"
  dce: "docker-compose exec"
  dp: "docker ps"
  dpa: "docker ps -a"
  dpl: "docker ps -l"
  dk: "docker kill"
  dn: "docker network"
  di: "docker images"
  dc: "docker commit"
  db: "docker build"
  dbl: "docker build"
  dpu: "docker pull"
  dtop: "docker top"
  dcin: "docker container inspect"
  dlo: "docker container logs"
  dcls: "docker container ls"
  dclsa: "docker container ls -a"
  dpo: "docker container port"
  dr: "docker container run"
  drit: "docker container run -it"
  drm: "docker container rm"
  "drm!": "docker container rm -f"
  dst: "docker container start"
  dstp: "docker container stop"
  dxc: "docker container exec"
  dxcit: "docker container exec -it"
  dib: "docker image build"
  dii: "docker image inspect"
  dils: "docker image ls"
  dipu: "docker image push"
  dirm: "docker image rm"
  dit: "docker image tag"
  dnc: "docker network create"
  dncn: "docker network connect"
  dndcn: "docker network disconnect"
  dni: "docker network inspect"
  dnls: "docker network ls"
  dnrm: "docker network rm"
  dvi: "docker volume inspect"
  dvls: "docker volume ls"
  dvprune: "docker volume prune"

  efish: "NVIM_APPNAME=lazyvim nvim ~/.config/fish/config.fish"
  enu: "NVIM_APPNAME=lazyvim nvim ~/.config/nushell/config.nu"
  ekara: "NVIM_APPNAME=lazyvim nvim ~/.config/karabiner/karabiner.edn"
  emux: "NVIM_APPNAME=lazyvim nvim ~/.config/tmux/tmux.conf"
  esl: "NVIM_APPNAME=lazyvim nvim ~/.config/lazyvim/lua"
  eyaro: "NVIM_APPNAME=lazyvim nvim ~/.config/aerospace/aerospace.toml"
  sc: "NVIM_APPNAME=lazyvim_clean nvim"
  sl: "NVIM_APPNAME=lazyvim nvim"

  conf: "sesh connect (sesh list | gum filter --limit 1 --placeholder 'Pick a sesh' --prompt='')"
  max: "blueutil --connect 70-F9-4A-9C-49-0F"
}

# fish's jk / xq / xw two-key binds and autopair have no reedline equivalent.
# !! and !$ (plugin-bang-bang) are built into nushell.
$env.config.keybindings ++= [
  { name: up_or_search, modifier: control, keycode: char_p, mode: [vi_insert vi_normal]
    event: { until: [{ send: menuup } { send: up }] } }
  { name: down_or_search, modifier: control, keycode: char_n, mode: [vi_insert vi_normal]
    event: { until: [{ send: menudown } { send: down }] } }
  # fish binds these swapped (ctrl-down = up, ctrl-up = down); kept as-is.
  { name: ctrl_down_up, modifier: control, keycode: down, mode: [vi_insert vi_normal]
    event: { until: [{ send: menuup } { send: up }] } }
  { name: ctrl_up_down, modifier: control, keycode: up, mode: [vi_insert vi_normal]
    event: { until: [{ send: menudown } { send: down }] } }
  { name: forward_word_or_hint, modifier: control, keycode: char_f, mode: vi_insert
    event: { until: [{ send: historyhintwordcomplete } { edit: movewordright }] } }
  { name: forward_char_or_hint, modifier: control, keycode: char_e, mode: vi_insert
    event: { until: [{ send: historyhintcomplete } { edit: moveright }] } }
]

# direnv has no nushell hook; this is the one from the nushell cookbook.
$env.config.hooks.pre_prompt = ($env.config.hooks.pre_prompt? | default [] | append {||
  if (which direnv | is-empty) { return }
  direnv export json | from json | default {} | load-env
  if ($env.PATH | describe) == "string" {
    $env.PATH = do $env.ENV_CONVERSIONS.PATH.from_string $env.PATH
  }
})

$env.config.keybindings ++= [
  {
    name: clear_line
    modifier: control
    keycode: char_u
    mode: [vi_insert vi_normal]
    event: { edit: clear }
  }
]

$env.config.keybindings ++= [{
    name: change_dir_with_fzf
    modifier: CONTROL
    keycode: Char_t
    mode: [vi_insert vi_normal]
    event: [
        { edit: Clear }
        {
          edit: InsertString,
          value: "cd (ls | where type == dir | each { |row| $row.name} | str join (char nl) | fzf | decode utf-8 | str trim)"
        }
        { send: Enter }
    ]
}]

# ctrl-r: fzf history picker like fish's `fzf --fish`; seeded with the current line.
$env.config.keybindings ++= [{
    name: fzf_history
    modifier: control
    keycode: char_r
    mode: [vi_insert vi_normal]
    event: {
        send: executehostcommand
        cmd: "commandline edit --replace (history | get command | reverse | uniq | to text | fzf --scheme=history --tiebreak=index -q (commandline) | str trim)"
    }
}]

