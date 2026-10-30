function dcd
  if test -z $argv
    docker-compose down --remove-orphans
  else
    docker-compose stop $argv
    docker-compose rm $argv
  end
end
