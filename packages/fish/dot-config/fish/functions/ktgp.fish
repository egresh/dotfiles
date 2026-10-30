function ktgp -d 'Kubectl -n test get pods'
  kubectl -n test get pods | grep -i $argv
end
