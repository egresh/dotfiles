print (ansi white) "Loading carapace..."
$env.PATH = ($env.PATH | split row (char esep) | where { $in != "/Users/egresh/.config/carapace/bin" } | prepend "/Users/egresh/.config/carapace/bin")

def --env get-env [name] { $env | get $name }
def --env set-env [name, value] { load-env { $name: $value } }
def --env unset-env [name] { hide-env $name }

# From the nushell cookbook's fish completer.
let fish_completer = {|spans|
  fish --command $"complete '--do-complete=($spans | str replace --all "'" "\\'" | str join ' ')'"
  | from tsv --flexible --noheaders --no-infer
  | rename value description
  | update value {|row|
    let value = $row.value
    let need_quote = ['\' ',' '[' ']' '(' ')' ' ' '\t' "'" '"' "`"] | any {$in in $value}
    if ($need_quote and ($value | path exists)) {
      let expanded_path = if ($value starts-with ~) {$value | path expand --no-symlink} else {$value}
      $'"($expanded_path | str replace --all "\"" "\\\"")"'
    } else {$value}
  }
}

let carapace_completer = {|spans|
  load-env {
  	CARAPACE_SHELL_BUILTINS: (help commands | where category != "" | get name | each { split row " " | first } | uniq  | str join "\n")
  	CARAPACE_SHELL_FUNCTIONS: (help commands | where category == "" | get name | each { split row " " | first } | uniq  | str join "\n")
  }

  # if the current command is an alias, get it's expansion
  let expanded_alias = (scope aliases | where name == $spans.0 | $in.0?.expansion?)

  # overwrite
  let spans = (if $expanded_alias != null  {
    # put the first word of the expanded alias first in the span
    $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
  } else {
    $spans | skip 1 | prepend ($spans.0)
  })

  # Hand-edited: fall back to fish's completions (omniwmctl, tinty, sesh,
  # workmux, ...) when carapace has none. CARAPACE_BRIDGES=fish finds nothing.
  let result = (carapace $spans.0 nushell ...$spans | from json)
  if ($result | is-not-empty) { $result } else { do $fish_completer $spans }
}

mut current = (($env | default {} config).config | default {} completions)
$current.completions = ($current.completions | default {} external)
$current.completions.external = ($current.completions.external
| default true enable
# backwards compatible workaround for default, see nushell #15654
| upsert completer { if $in == null { $carapace_completer } else { $in } })

$env.config = $current
    
