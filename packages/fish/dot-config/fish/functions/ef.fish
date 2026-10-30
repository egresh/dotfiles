function ef
  set -f file

  if test -z $argv
    set file $(fasd -Rfl | fzf --border --margin 5% --preview 'bat --color always {}')
  else
    set file $(fasd -Rfl | fzf -q $argv --border --margin 5% --preview 'bat --color always {}')
  end

  if test -z $file
    return
  else
    $EDITOR $file
  end
end
