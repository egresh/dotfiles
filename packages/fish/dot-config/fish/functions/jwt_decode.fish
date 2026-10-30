function jwt_decode -d "decode JWT"
  jq -R 'split(".") | .[] | @base64d | fromjson' < $argv
end
