#!/usr/bin/env bash

DOT_FILES=~/dev/newdots
CONFIG_DIR=~/.config
YABAI_DIR=$CONFIG_DIR/yabai
KITTY_DIR=$CONFIG_DIR/kitty
SKHD_DIR=$CONFIG_DIR/skhd
BIN_DIR=~/bin
GIT_DIR=$HOME
ACTION=install

cd $DOT_FILES || exit

yabai() {
  echo "Executing yabai $1"

  case $1 in
    install)
      if ! [ -d $YABAI_DIR ]; then
        mkdir -p $YABAI_DIR
      fi

      stow -v -t $YABAI_DIR -S yabai
      ;;
      
    uninstall)
      stow -v -t $YABAI_DIR -D yabai
      rmdir $YABAI_DIR
      ;;

    *)
      echo -n "unknown..."
      ;;
  esac
}

skhd() {
  echo "Executing skhd $1"

  case $1 in
    install)
      stow -v -t $SKHD_DIR -S skhd --dotfiles -v
      ;;
      
    uninstall)
      stow -v -t $SKHD_DIR -D skhd --dotfiles -v
      ;;

    *)
      echo -n "unknown..."
      ;;
  esac
}

bindir() {
  echo "Executing bindir $1"

  case $1 in
    install)
      if ! [ -d $BIN_DIR ]; then
        mkdir -p $BIN_DIR
      fi

      stow -v -t $BIN_DIR -S bin
      ;;
      
    uninstall)
      stow -v -t $BIN_DIR -D bin
      rmdir $BIN_DIR
      ;;

    *)
      echo -n "unknown..."
      ;;
  esac
}

git() {
  echo "Executing git $1"

  case $1 in
    install)
      stow -v -t $GIT_DIR -S git --dotfiles
      ;;
      
    uninstall)
      stow -v -t $GIT_DIR -D git --dotfiles
      ;;

    *)
      echo -n "unknown..."
      ;;
  esac
}

zsh() {
  echo "Executing git $1"

  case $1 in
    install)
      stow -t $HOME -S zshell --dotfiles -v --ignore='.*\.zsh$'
      ;;
      
    uninstall)
      stow -t $HOME -D zshell --dotfiles -v --ignore='.*\.zsh$'
      ;;

    *)
      echo -n "unknown..."
      ;;
  esac
}

tmux() {
  echo "Executing tmux $1"

  case $1 in
    install)
      stow -t $HOME -S tmux --dotfiles -v
      ;;

    uninstall)
      stow -t $HOME -D tmux --dotfiles -v
      ;;

    *)
      echo -n "unknown..."
      ;;
  esac
}

kitty() {
  echo "Executing kitty $1"

  case $1 in
    install)
      stow -t $KITTY_DIR -S kitty -v
      ;;
      
    uninstall)
      stow -t $KITTY_DIR -D kitty -v
      ;;

    *)
      echo -n "unknown..."
      ;;
  esac
}

misc() {
  echo "Executing misc $1"

  case $1 in
    install)
      stow -t $HOME -S misc --dotfiles -v
      ;;
      
    uninstall)
      stow -t $HOME -D misc --dotfiles -v
      ;;

    *)
      echo -n "unknown..."
      ;;
  esac
}

efm_langserver() {
  echo "Executing efm_langserver $1"

  case $1 in
    install)
      stow -t $CONFIG_DIR -S efm-langserver -v
      ;;
      
    uninstall)
      stow -t $CONFIG_DIR -D efm-langserver -v
      ;;

    *)
      echo -n "unknown..."
      ;;
  esac
}

hammerspoon() {
  echo "Executing hammerspoon $1"

  case $1 in
    install)
      stow -t $HOME -S hammerspoon --dotfiles -v
      ;;
      
    uninstall)
      stow -t $HOME -D hammerspoon --dotfiles -v
      ;;

    *)
      echo -n "unknown..."
      ;;
  esac
}

vim() {
  echo "Executing vim $1"

  case $1 in
    install)
      stow -t "$HOME" -S vim --dotfiles -v
      ;;
      
    uninstall)
      stow -t "$HOME" -D vim --dotfiles -v
      ;;

    *)
      echo -n "unknown..."
      ;;
  esac
}

karabiner() {
  echo "Executing karabiner $1"

  case $1 in
    install)
      stow -t "$CONFIG_DIR" -S karabiner -v
      ;;

    uninstall)
      stow -t "$CONFIG_DIR" -D karabiner -v
      ;;

    *)
      echo -n "unknown..."
      ;;
  esac
}

#yabai 'install'
#bindir 'install'
# git 'install'
# zsh 'install'
tmux 'install'
#misc 'install'
# efm_langserver 'install'
# hammerspoon 'install'
# xbar 'install'
# vim 'install'
# kitty install
# karabiner install
