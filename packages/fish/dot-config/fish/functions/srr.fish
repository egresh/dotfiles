function srr
  if test -z $argv
    mutagen-compose down --remove-orphans
  else
    mutagen-compose stop $argv
    mutagen-compose rm -f $argv
  end
end
