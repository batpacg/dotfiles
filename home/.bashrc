#
# ~/.bashrc
#

source_if_exists() {
    # shellcheck disable=1090
    [ -f "$1" ] && . "$1"
}

source_if_exists "$HOME/.config/shell/environment"

# Return if not interactive.
if [[ $- != *i* ]]; then
    unset source_if_exists
    return
fi

source_if_exists "$HOME/.config/shell/aliases"
source_if_exists "$HOME/.config/shell/functions"

unset source_if_exists

# ==============================================================================
# Custom Prompt
# https://superuser.com/questions/187455/right-align-part-of-prompt/1203400#1203400
# Arch Wiki
# ==============================================================================

PROMPT_DIRTRIM=4
PS1='\n\[\e[97m\]\[\e[1m\]\w\[\e[0m\] $([ $? -eq 0 ] || echo -e "\e[31m$?\e[0m")\n\[\e[97m\]\$\[\e[0m\] '

# ==============================================================================
# Plugins
# ==============================================================================

eval "$(direnv hook bash)"
eval "$(zoxide init bash)"
command -v z >/dev/null 2>&1 && alias cd="z"

# ==============================================================================
# Custom Keybinds
# ==============================================================================

# To yank the current line to the system's clipboard using OSC52.
yank_like_to_cb() {
    printf "\e]52;c;%s\a" "$(printf %s "$READLINE_LINE" | openssl base64 -A)"
}
bind -x '"\C-y": yank_like_to_cb'
