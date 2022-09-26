RED="%{[38;05;009m%}"
ORANGE="%{[38;05;208m%}"
YELLOW="%{[38;05;003m%}"
LAVENDER="%{[38;05;141m%}"
BLUE="%{[38;05;075m%}"
GREEN="%{[38;05;002m%}"
RESET="%{[0m%}"

PROMPT_STRING="
${RED}❮%(!.${RED}%n.${YELLOW}%n)${RED}::${YELLOW}%m"   # user::hostname
PROMPT_STRING="$PROMPT_STRING ${ORANGE}[%D{%k:%M:%S}]" # colorized date
PROMPT_STRING="$PROMPT_STRING %2~${RED}❯$RESET"        # path component
PROMPT_STRING="$PROMPT_STRING \$(git_prompt_info)"     # git status
PROMPT_STRING="$PROMPT_STRING \$(git_prompt_status)"
PROMPT_STRING="$PROMPT_STRING
%(?.${GREEN}➔${RESET}.${RED}➔${RESET}) "               # exit status

PS1=$PROMPT_STRING

#ZSH_THEME_GIT_PROMPT_PREFIX=" ${RED}«git»${RESET} %U${GREEN}"
#ZSH_THEME_GIT_PROMPT_SUFFIX="${RESET}"
#ZSH_THEME_GIT_PROMPT_DIRTY="%u"
#ZSH_THEME_GIT_PROMPT_CLEAN="%u ${GREEN}✓"
#ZSH_THEME_GIT_PROMPT_ADDED="${RED} add"
#ZSH_THEME_GIT_PROMPT_MODIFIED="${ORANGE} mod"
#ZSH_THEME_GIT_PROMPT_DELETED="${LAVENDER} del"
#ZSH_THEME_GIT_PROMPT_UNTRACKED="${YELLOW} untrk"
#ZSH_THEME_GIT_PROMPT_RENAMED="${RED} ren"
#ZSH_THEME_GIT_PROMPT_STAGED="${RED} st"
#ZSH_TqEME_GIT_PROMPT_STASHED="${RED} stsh"
#ZSH_TqEME_GIT_PROMPT_UNMERGED="${RED} unmrg"
#ZSH_THEME_GIT_PROMPT_AHEAD="${RED} ahd"
#ZSH_THEME_GIT_PROMPT_BEHIND="${RED} ●bhnd"
#ZSH_THEME_GIT_PROMPT_DIVERGED="${RED} ●dvrgd"
#ZSH_THEME_GIT_PROMPT_SHA_AFTER=""
#ZSH_THEME_GIT_PROMPT_SHA_BEFORE=""
#ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE=""
#ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE=""
#ZSH_THEME_GIT_PROMPT_DIVERGED_REMOTE=""

function gitoff {

PROMPT_STRING="
${RED}❮%(!.${RED}%n.${YELLOW}%n)${RED}::${YELLOW}%m"   # user::hostname
PROMPT_STRING="$PROMPT_STRING ${ORANGE}[%D{%k:%M:%S}]" # colorized date
PROMPT_STRING="$PROMPT_STRING %2~${RED}❯$RESET"        # path component
PROMPT_STRING="$PROMPT_STRING
%(?.${GREEN}➔${RESET}.${RED}➔${RESET}) "               # exit status

PS1=$PROMPT_STRING
}

function giton {

PROMPT_STRING="
${RED}❮%(!.${RED}%n.${YELLOW}%n)${RED}::${YELLOW}%m"   # user::hostname
PROMPT_STRING="$PROMPT_STRING ${ORANGE}[%D{%k:%M:%S}]" # colorized date
PROMPT_STRING="$PROMPT_STRING %2~${RED}❯$RESET"        # path component
PROMPT_STRING="$PROMPT_STRING \$(git_prompt_info)"     # git status
PROMPT_STRING="$PROMPT_STRING \$(git_prompt_status)"
PROMPT_STRING="$PROMPT_STRING
%(?.${GREEN}➔${RESET}.${RED}➔${RESET}) "               # exit status

PS1=$PROMPT_STRING
}

function ztheme {

    _use_theme=$1
    _zsh_theme_dir=~/.oh-my-zsh/themes
    
    if [ "$_use_theme" = "random" ]; then
       
        string='@themes = glob "'
        string="${string}${_zsh_theme_dir}/*\""
        string="$string; \$var = int(rand(@themes - 1));"
        string="$string \$new_theme = \$themes[\$var];"
        string="$string \$qm = quotemeta(\"$_zsh_theme_dir\");"
        string="$string \$new_theme =~ s/\$qm\///;"
        string="$string \$new_theme =~ s/.zsh-theme//;"
        string="$string print \$new_theme"

        _pick=`perl -E $string`

        ztheme $_pick

        return
    fi

    if [ -z "$_use_theme" ]; then

        if [ -z "$CURRENT_THEME" ]; then

            CURRENT_THEME=$(grep "^ZSH_THEME" ~/.zshrc | \
            perl -wnale 's/"//g; $var = (split "=", $_)[1]; print $var')
        fi
    else
        _new_theme="$_zsh_theme_dir/$_use_theme.zsh-theme"

        if [ -f "$_new_theme" ]; then

            CURRENT_THEME=$(echo $_use_theme | sed -e s/\n//g)
            source $_new_theme

        else

            echo "Theme $_use_theme not found"
            return
        fi
    fi

    echo "Using theme: $CURRENT_THEME"
}

