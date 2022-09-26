export REAL_BLACK=232
export LIGHT_BLACK=239

# Context segment only prints if you are not the DEFAULT_USER
export DEFAULT_USER=egresh

export POWERLEVEL9K_MODE='nerdfont-complete'

# Items on the left prompt
#POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status vi_mode dir_writable command_execution_time context dir rvm vcs)
export POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status vi_mode dir_writable command_execution_time context dir custom_rvm_command vcs)

# Use a custom RVM prompt activated when RVMP is not 0 length
export POWERLEVEL9K_CUSTOM_RVM_COMMAND="display_rvm_info"
export POWERLEVEL9K_CUSTOM_RVM_COMMAND_BACKGROUND=1
export POWERLEVEL9K_CUSTOM_RVM_COMMAND_FOREGROUND=0

display_rvm_info() {
    if [ -n "$RVMP" ]; then
        echo "  `~/.rvm/bin/rvm-prompt v g`"
    fi
}

# Items on the right prompt
export POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

# Use a right prompt?
export POWERLEVEL9K_DISABLE_RPROMPT=true

# Command input on the 2nd line
export POWERLEVEL9K_PROMPT_ON_NEWLINE=true

# Don't print the right prompt on the 2nd line
export POWERLEVEL9K_RPROMPT_ON_NEWLINE=false

# Don't print anything before the prompt
# POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
if [ -n "$NVIM_LISTEN_ADDRESS" ]; then
  export POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%F{86}╭─\ue62b %f"
else
  export POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%F{86}╭─%f"
fi

# Command input characters
#POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='╰─>>> '  # " "
export POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%F{86}╰─\uF460\uF460\uF460%f '  # " "

# CR before prompt is printed (blank line between output and prompt)
export POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

# Duh
export POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=""

# unset for dir_writable, it prints this, not the LEFT_SEGMENT_SEPARATOR
export POWERLEVEL9K_DIR_WRITABLE_FORBIDDEN_BACKGROUND="clear"
export POWERLEVEL9K_DIR_WRITABLE_FORBIDDEN_FOREGROUND="red"
export POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=
export POWERLEVEL9K_ROOT_INDICATOR_BACKGROUND="red"
export POWERLEVEL9K_ROOT_INDICATOR_FOREGROUND="white"

# For status segment.
export POWERLEVEL9K_CARRIAGE_RETURN_ICON="\uf467"

export POWERLEVEL9K_VI_INSERT_MODE_STRING="\ue27a"
export POWERLEVEL9K_VI_COMMAND_MODE_STRING="\ue295"
export POWERLEVEL9K_VI_MODE_NORMAL_FOREGROUND="yellow"
export POWERLEVEL9K_VI_MODE_NORMAL_BACKGROUND=$LIGHT_BLACK
export POWERLEVEL9K_VI_MODE_INSERT_FOREGROUND=118
export POWERLEVEL9K_VI_MODE_INSERT_BACKGROUND=$LIGHT_BLACK

export POWERLEVEL9K_STATUS_CROSS=false
export POWERLEVEL9K_STATUS_OK=false
export POWERLEVEL9K_STATUS_ERROR_BACKGROUND=$LIGHT_BLACK
export POWERLEVEL9K_STATUS_ERROR_FOREGROUND="red"

export POWERLEVEL9K_RVM_BACKGROUND=1
export POWERLEVEL9K_RVM_FOREGROUND=0
export POWERLEVEL9K_RVM_VISUAL_IDENTIFIER_COLOR=0

export POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0
export POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND="red"
export POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=$LIGHT_BLACK
export POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=86
export POWERLEVEL9K_COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_COLOR=86
export POWERLEVEL9K_EXECUTION_TIME_ICON=''

#      
export POWERLEVEL9K_FOLDER_ICON='' #     
export POWERLEVEL9K_DIR_HOME_BACKGROUND=$LIGHT_BLACK
export POWERLEVEL9K_DIR_HOME_BACKGROUND=0
export POWERLEVEL9K_DIR_HOME_FOREGROUND="white"
export POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND=$LIGHT_BLACK
export POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND="white"
export POWERLEVEL9K_DIR_DEFAULT_BACKGROUND="black"
export POWERLEVEL9K_DIR_DEFAULT_FOREGROUND=227
export POWERLEVEL9K_DIR_DEFAULT_VISUAL_IDENTIFIER_COLOR="red"
export POWERLEVEL9K_SHORTEN_DIR_LENGTH=10
export POWERLEVEL9K_SHORTEN_STRATEGY='truncate_from_right'

export POWERLEVEL9K_VCS_GIT_ICON=
export POWERLEVEL9K_VCS_CLEAN_FOREGROUND=0
export POWERLEVEL9K_VCS_CLEAN_BACKGROUND=82
export POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=0
export POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND=184
export POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=0
export POWERLEVEL9K_VCS_MODIFIED_BACKGROUND=208

#source /usr/local/opt/powerlevel9k/powerlevel9k.zsh-theme