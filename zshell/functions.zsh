function dockerd {
    if  [[ -z $1     ]] || [[ -z $2     ]] || \
        ([[ $1 != 'i' ]] && [[ $1 != 'c' ]]); then
      echo "First argument is 'i<mage>' or 'c<ontainer>'"
      echo "Second argument is the number of old targets to delete"
      return
    fi

    local _to_delete=$2
    local _target=$1
    local _images
    local _image_count
    local _will_delete
    local _answer

    if [[ $_target == "i" ]]; then
        _images=$(docker images | grep -v '^REPOSITORY')
    else
        _images=$(docker ps -a | grep -v '^CONTAINER')
    fi

    _image_count=$(echo "$_images" | wc -l | tr -d "[:space:]")

    if   [[ -z $_images ]] ; then
        echo "-> No images found"
        return
    fi

    _will_delete=$(expr $_image_count - $_to_delete)

    if [[ $_will_delete -le 0 ]]; then
        _will_delete=$_image_count
    fi

    echo $_images | perl -wnale "print \"\$. -> \$_\" \
        if (\$. > $_will_delete) || ($_will_delete == $_image_count)"

    echo
    if [[ $_will_delete -eq $_image_count ]] ; then
        echo "*** This will delete ALL images or containers ***"
    fi

    echo -n "Remove $_will_delete images or containers <y/n> -> "
    read _answer
    echo

    if ! echo $_answer | egrep -q '^[Yy]$' ; then
        echo "ABORTED"
        return
    fi

    _count=1
    if [[ $_target == 'i' ]]; then
        echo $_images | awk '{print $3}' | while read line; do
            if [[ $_count -gt $_will_delete ]] || [[ $_will_delete -eq $_image_count ]] ; then
                docker rmi $line > /dev/null && echo "Deleted: $line"
            fi
            let _count++
        done
    else
        echo $_images | awk '{print $1}' | while read line; do
            if [[ $_count -gt $_will_delete ]] || [[ $_will_delete -eq $_image_count ]] ; then
                docker rm $line > /dev/null && echo "Deleted: $line"
            fi
            let _count++
        done
    fi
}

function g() {
    if [[ $# > 0 ]]; then
        git $@
    else
        git status
    fi
}

# Make zsh recgonize 'g' as a command for completions
compdef g=git

# Add a load average line to the top of the terminal
function lavg {

    if [ -z "$_SAVED_PS1" ]; then

        _SAVED_PS1=$PS1

        local _up1=$(uptime | cut -d ' ' -f 12)
        local _up2=$(uptime | cut -d ' ' -f 13)
        local _up3=$(uptime | cut -d ' ' -f 14)

        local _up1length=${#_up1}
        local _up2length=${#_up2}
        local _up3length=${#_up3}

        # this is the space
        local _hostname=${HOSTNAME%%.*}
        local _hslength=${#_hostname}

        local pos=$(( _up1length + _up2length + _up3length + _hslength + 3 ))
        local _setup1="\[${txtrst}\]\[\033[s\]\[\033[3;\$(( COLUMNS - $pos ))f\]"
        local _setup2="$_hostname: \[${txtred}\]$_up1 \[${txtylw}\]$_up2 \[${bldblu}\]$_up3"
        local _setup3="\[${txtrst}\]\[\033[u\]"

        PS1="${_setup1}${_setup2}${_setup3}$PS1"
    else
        PS1=$_SAVED_PS1
        _SAVED_PS1=
    fi
}

fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}

function zcus() {
    current_dir=`pwd`
    cd ~/dev/dotfiles/zshell
    file=$(/bin/ls | fzf-tmux -0)
    [ -z $file ] && return
    vi $file
    cd $current_dir
}

function ad {
    opaque=$1

    if [[ -z "$opaque" ]]; then
        opaque="1.0"
    elif [[ ! "$opaque" =~ [0-9] ]]; then
        return
    else
        opaque="0.$opaque"
    fi

    perl -pi -e "s/^(background_opacity: )(.*)/\1 $opaque/" ~/.config/alacritty/alacritty.yml
}

function ff {
    export param=$1

    file=$(
        zsh << '    FOO'
          trap 'echo ""' INT

          if [[ -z "$param" ]]; then
              file=$(fasd -fl | fzf --border --margin 5% )
          else
              file=$(fasd -fl | fzf -q $param --border --margin 5%)
          fi

          echo $file
    FOO
)

  [[ -z "$file" ]] && return

  vi $file
}

function fdd {
    export param=$1

    dir=$(
        zsh << '    FOO'
          trap 'echo ""' INT

          if [[ -z "$param" ]]; then
              dir=$(fasd -dl | fzf )
          else
              dir=$(fasd -dl | fzf -q $param)
          fi

          echo $dir
    FOO
)

  [[ -z "$dir" ]] && return

  cd $dir
}

function vcus() {
	file=$(
	  /usr/bin/env ruby << '      EORUBY' | fzf -0
		nvim = File.join(ENV['HOME'], ".vim")
		%w{config ftplugin}.each do |dir|
			files = Dir.glob("#{File.join(nvim, dir)}/*")
			files.each {|f| puts f}
		end
      EORUBY
	)
    [ -z $file ] && return
    nvim $file
}

function neo() {
    _NVIM_LISTEN_ADDRESS=/tmp/nvimsocket
    if [ -e $_NVIM_LISTEN_ADDRESS ] ; then
        if [ -z $1 ] ; then
            echo "What do you want to open?"
            echo
        fi
        NVIM_LISTEN_ADDRESS=$_NVIM_LISTEN_ADDRESS nvr $1
    else
        nvim $1
    fi
}

function gitoff() {
    _TMP=()
    for item in ${POWERLEVEL9K_LEFT_PROMPT_ELEMENTS[*]}
    do
        if ! [[ $item =~ 'vcs' ]]; then
        _TMP+=($item)
        fi
    done

    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=($_TMP)
}

function giton() {
    gitoff
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS+=(vcs)
}

function poof() {
    space=$1
    yabai -m space $space --destroy
}

