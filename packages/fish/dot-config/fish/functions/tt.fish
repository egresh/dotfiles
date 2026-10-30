function tt
  set -l level

  if test -z $argv
      set level 1
  else
      set level $argv
  end

  eza --tree --git --level=$level
end
