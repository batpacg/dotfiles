#
# ~/.bashrc
#

# Environment ==================================================================

appendpath() {
	local dir=$1
	case ":$PATH:" in
		*:"$dir":*) ;;
		*)
			export PATH="$dir:$PATH"
			;;
	esac
}

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

export EDITOR=nvim
export VISUAL=neovide
export PAGER="less -R"
export BROWSER=zen-browser
export TERMINAL=kitty
export TERMINAL_PROG=kitty

export XINITRC="$XDG_CONFIG_HOME/x11/xinitrc"

export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc-2.0"

# export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
# export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export WINEPREFIX="$XDG_DATA_HOME/wineprefixes/default"
export TMUX_TMPDIR="$XDG_RUNTIME_DIR"
export ANSIBLE_CONFIG="$XDG_CONFIG_HOME/ansible/ansible.cfg"
# export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export IPYTHONDIR="$XDG_CONFIG_HOME/ipython"
export SQLITE_HISTORY="$XDG_DATA_HOME/sqlite_history"

export TREESITTER_DIR="$XDG_DATA_HOME/tree-sitter"

export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
appendpath "$CARGO_HOME/bin"

export GOPATH="$XDG_DATA_HOME/go"
export GOMODCACHE="$XDG_CACHE_HOME/go/mod"
appendpath "$GOPATH/bin"

export LUAROCKS_HOME="$XDG_DATA_HOME/luarocks"

export LUA_PATH="$LUA_PATH;./?.lua"
export LUA_PATH="$LUA_PATH;./?/init.lua"
export LUA_PATH="$LUA_PATH;/usr/lib/lua/5.3/?.lua"
export LUA_PATH="$LUA_PATH;/usr/share/lua/5.3/?/init.lua"
export LUA_PATH="$LUA_PATH;/usr/lib/lua/5.3/?/init.lua"
export LUA_PATH="$LUA_PATH;$LUAROCKS_HOME/share/lua/5.3/?.lua"
export LUA_PATH="$LUA_PATH;$LUAROCKS_HOME/share/lua/5.3/?/init.lua"

export LUA_CPATH="$LUA_CPATH;./?.so"
export LUA_CPATH="$LUA_CPATH;/usr/lib/lua/5.3/?.so"
export LUA_CPATH="$LUA_CPATH;/usr/lib/lua/5.3/loadall.so"
export LUA_CPATH="$LUA_CPATH;$LUAROCKS_HOME/lib/lua/5.3/?.so"

export npm_config_prefix="$XDG_DATA_HOME/npm"
export npm_config_cache="$XDG_CACHE_HOME/npm"
appendpath "${npm_config_prefix}/bin"

export PNPM_HOME="$XDG_DATA_HOME/pnpm"
appendpath "$PNPM_HOME"

export LOCAL_BIN="$HOME/.local/bin"
appendpath "$LOCAL_BIN"
for dir in "$LOCAL_BIN"/*; do
	[ -d "$dir" ] && appendpath "$dir"
done

export LESS_TERMCAP_md=$'\E[1;33m'     # begin bold
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin standout
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blinking
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_se=$'\E[0m'        # end standout
export LESS_TERMCAP_me=$'\E[0m'        # end mode
export LESS_TERMCAP_ue=$'\E[0m'        # end underline

unset -f appendpath

# Return if not interactive.
if [[ $- != *i* ]]; then
	unset source_if_exists
	return
fi

# Aliases ======================================================================

alias ..="cd .."
alias ....="cd ../.."

alias clera="clear"
alias clare="clear"
alias claer="clear"
alias cler="clear"
alias clar="clear"

alias diff="colordiff -u"

alias venvon="source ./.venv/bin/activate"

alias ssh="TERM=xterm-256color ssh"

if command -v tmux > /dev/null 2>&1; then
	alias ta="tmux new -s main -A"
	alias tks="tmux kill-server"
	alias tls="tmux list-sessions"
fi

if command -v eza > /dev/null 2>&1; then
	alias ls='eza -1 --icons=always --group-directories-first'
	alias ll='eza -a -lg --no-time --icons=always --group-directories-first'
else
	alias ls="ls --color=auto -F1 --group-directories-first"
	alias la="ls --color=auto -FA1 --group-directories-first"
	alias ll="ls --color=auto -FAl1 --group-directories-first"
fi

# https://aria2.org/
if command -v aria2c > /dev/null 2>&1; then
	alias aria="aria2c -x 16 -s 16 --enable-dht=true --bt-enable-lpd=true"
fi

# Functions ====================================================================

yacd() {
	local tmp cwd
	tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp" || true
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd" || true
	rm -f -- "$tmp"
}

man() {
	env \
		LESS=R \
		GROFF_NO_SGR=0 \
		MANPAGER="less -R" \
		LC_CTYPE=en_US.UTF-8 \
		man "$@"
}

tfont() {
	echo -e "Normal Text: Est sit ipsam et sunt aut atque rerum deleniti."
	echo -e "\e[1mBold Text: Est sit ipsam et sunt aut atque rerum deleniti.\e[0m"
	echo -e "\e[3mItalic Text: Est sit ipsam et sunt aut atque rerum deleniti.\e[0m"
	echo -e "\e[3m\e[1mBold & Italic Text: Est sit ipsam et sunt aut atque rerum deleniti.\e[0m"
	echo -e "\e[4mUnderline Text\e[0m"
	echo -e "\e[9mStrikethrough Text\e[0m"
	echo -e "\e[31mRed Text\e[0m"
	echo -e "\x1B[31mError? Text\e[0m"
	echo -e "Ligatures:== != >= <= => === !=== --- ___ $ & % @ ^"
	echo -e "Icons:契          勒 鈴 "
	echo "Box characters:"
	for i in {0..127}; do
		printf -v hex "%02x" "$i"
		printf "\u25$hex "
		if [ $(((i + 1) % 16)) -eq 0 ]; then
			echo
		fi
	done
}

export FZF_DEFAULT_OPTS="--reverse --ansi --prompt='» '"

fe() {
	local selected
	selected="$(fd . "$@" --follow --hidden --type file | fzf --reverse)"
	if [ -n "$selected" ]; then
		$EDITOR "$selected"
	fi
}

fcd() {
	local selected
	selected="$(
		fd . "$@" --follow --hidden --type dir --exclude ".git" | fzf --reverse
	)"
	[ -n "$selected" ] && cd "$selected" || return
}

fkill() {
	local pid
	pid="$(ps -e | fzf --accept-nth=1)"
	[ -n "$pid" ] && kill "$pid"
}

fserv() {
	systemctl list-units | grep .service | sed 's/ \{2,\}/\t/g' | cut -d $'\t' -f 2- | fzf
}

fuserv() {
	systemctl --user list-units | grep .service | sed 's/ \{2,\}/\t/g' | cut -d $'\t' -f 2- | fzf
}

# Prompt =======================================================================

# shopt -s checkwinsize
#
# _prompt_separator() {
# 	[ -z "$COLUMNS" ] && return
# 	local sepchar="—"
# 	printf -v sepstring "%${COLUMNS}s" ""
# 	echo -e "\e[37m${sepstring// /${sepchar}}\e[0m"
# }
#
# # http://heyrod.com/snippets/how-to-right-align-bash-prompt.html
# _prompt_pwd_exitcode_hr() {
# 	local sepchar="—"
# 	local dir="${1/"${HOME}"/\~} "
# 	printf -v hr "%${COLUMNS}s" ""
# 	hr="${hr// /${sepchar}}"
# 	echo -en "$dir${hr:${#dir}}"
# }
#
# PROMPT_COMMAND+=(echo)

_prompt_exitcode() {
	last=$?
	[ $last -ne 0 ] && echo -en "\e[31m$last\e[0m"
}

GRAY='\[\e[37m\]'
BOLD='\[\e[1m\]'
RESET='\[\e[0m\]'

PROMPT_DIRTRIM=4
PS1="${GRAY}${BOLD}\w${RESET} \$(_prompt_exitcode)\n${GRAY}»${RESET} "

unset GREEN
unset BOLD
unset RESET

# https://stackoverflow.com/questions/19609770/add-newline-after-output-of-every-bash-command
PROMPT_COMMAND="export PROMPT_COMMAND=echo"
alias clear="unset PROMPT_COMMAND; clear; PROMPT_COMMAND='export PROMPT_COMMAND=echo'"

# Keybinds =====================================================================

stty -ixon

# To yank the current line to the system's clipboard using OSC52.
yank_like_to_cb() {
	printf "\e]52;c;%s\a" "$(printf %s "$READLINE_LINE" | openssl base64 -A)"
}

bind -x '"\C-y": yank_like_to_cb'

# Plugins ======================================================================

eval "$(fzf --bash)"
eval "$(direnv hook bash)"
eval "$(zoxide init bash)"
command -v z > /dev/null 2>&1 && alias cd="z"
_ZO_DOCTOR=0
