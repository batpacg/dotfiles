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

export FZF_DEFAULT_OPTS="--reverse --ansi"

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

alias ls="ls --color=auto -F1 --group-directories-first"
alias la="ls --color=auto -FA1 --group-directories-first"
alias ll="ls --color=auto -FAl1 --group-directories-first"

alias clera="clear"
alias clare="clear"
alias claer="clear"
alias cler="clear"
alias clar="clear"

alias diff="colordiff -u"

alias ssh="TERM=xterm-256color ssh"
alias ta="tmux new -s main -A"
alias tks="tmux kill-server"
alias tls="tmux list-sessions"

# Functions ====================================================================

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
}

pac() {
	local subcommand="$1"
	local fzf="fzf --reverse --wrap"

	shift
	case "$subcommand" in
		-*) sudo pacman "$subcommand" "$@" ;;
		q | query) pacman -Ss "$@" ;;
		fq | fquery)
			pacman -Ss "$@" --color=always | paste - - | $fzf
			;;
		s | sync) sudo pacman -S "$@" ;;
		fs | fsync)
			local pkg
			pkg="$(pacman -Ss "$@" --color=always | paste - - | $fzf)"
			[ -z "$pkg" ] && return
			pkg="${pkg#*/}"  # trim left
			pkg="${pkg%% *}" # trim right
			sudo pacman -S "$pkg"
			;;
		u | update) sudo pacman -Syyu ;;
		r | remove) sudo pacman -Rs "$@" ;;
		*)
			local selected
			selected="$(pacman -Qs | fzf)"
			;;
	esac
}

norm() {
	local file="$1"

	local newname
	newname="$(
		echo "$file" |
			tr '[:upper:]' '[:lower:]' |
			tr ' ' '-' |
			tr '(' '_' |
			tr '[' '_' |
			tr -d '\\' |
			tr -d ')' |
			tr -d ']' |
			tr -d ',' |
			sed 's/-_/_/g; s/_-/_/g'
	)"

	mv "$file" "$newname"
}

fserv() {
	systemctl list-units | grep .service | sed 's/ \{2,\}/\t/g' | cut -d $'\t' -f 2- | fzf
}

fuserv() {
	systemctl --user list-units | grep .service | sed 's/ \{2,\}/\t/g' | cut -d $'\t' -f 2- | fzf
}

# Prompt =======================================================================

PROMPT_DIRTRIM=4
PROMPT_COMMAND+=(echo)
PS1='\[\e[37m\]\[\e[1m\]\w\[\e[0m\] $(last=$?; [ $last -eq 0 ] || echo -e "\e[31m$last\e[0m")\n\[\e[37m\]\$\[\e[0m\] '

# Plugins ======================================================================

eval "$(fzf --bash)"
eval "$(direnv hook bash)"
eval "$(zoxide init bash)"
command -v z > /dev/null 2>&1 && alias cd="z"

# Keybinds =====================================================================

stty -ixon

# To yank the current line to the system's clipboard using OSC52.
yank_like_to_cb() {
	printf "\e]52;c;%s\a" "$(printf %s "$READLINE_LINE" | openssl base64 -A)"
}

bind -x '"\C-y": yank_like_to_cb'
