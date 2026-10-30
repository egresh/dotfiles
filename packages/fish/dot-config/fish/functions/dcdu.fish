# down and back up
function dcdu
  if test -z $argv
    echo usage: dcdu service-name …
  else
    mutagen-compose stop $argv
    mutagen-compose rm -f $argv
    mutagen-compose up -d $argv
  end
end
