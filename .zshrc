# ------------------------------------------------------------------------------
# Settings
# ------------------------------------------------------------------------------

# Emacs Bindings
bindkey -e

# Options
setopt appendhistory autocd extendedglob nomatch notify
unsetopt beep

# Completion
setopt complete_aliases
zstyle ':completion:*' completer _complete _ignored _approximate
zstyle ':completion:*' matcher-list '' '' '' ''
zstyle :compinstall filename "$HOME/.zshrc"
autoload -Uz compinit
compinit

# ------------------------------------------------------------------------------
# zinit
# ------------------------------------------------------------------------------

# Install zinit if not installed
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
  print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma/zinit)…%f"
  command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
  command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
    print -P "%F{33}▓▒░ %F{34}Installation successful.%f" || \
    print -P "%F{160}▓▒░ The clone has failed.%f"
fi

# Load zinit
source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Plugins
zplugin light zdharma/fast-syntax-highlighting
zplugin light zsh-users/zsh-autosuggestions
zplugin light zdharma/history-search-multi-word
zplugin light denysdovhan/spaceship-prompt

# ------------------------------------------------------------------------------
# Environment
# ------------------------------------------------------------------------------

export SHELL='/bin/zsh'
export EDITOR=nvim
export WORDCHARS=${WORDCHARS//[\/\.]}
export BROWSER='none'

export HISTFILE=~/.zsh_history
export HISTSIZE=1000
export SAVEHIST=1000

export SPACESHIP_PROMPT_ORDER=(
  time          # Time stamps section
  user          # Username section
  dir           # Current directory section
  host          # Hostname section
  git           # Git section (git_branch + git_status)
  node          # Node.js section
  line_sep      # Line break
  battery       # Battery level and status
  vi_mode       # Vi-mode indicator
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.luarocks/bin:$PATH"

# ------------------------------------------------------------------------------
# Lua
# ------------------------------------------------------------------------------

function _generate_lua_path_ {
  declare -a LUA_PATH_PARTS=(
    "./?.lua"
    "./?/init.lua"
    "$HOME/.luarocks/share/lua/$1/?.lua"
    "$HOME/.luarocks/share/lua/$1/?/init.lua"
    "/usr/local/share/lua/$1/?.lua"
    "/usr/local/share/lua/$1/?/init.lua"
    "/usr/share/lua/$1/?.lua"
    "/usr/share/lua/$1/?/init.lua"
    "/usr/lib/lua/$1/?.lua"
    "/usr/lib/lua/$1/?/init.lua"
  )
  GENERATED_LUA_PATH=$(IFS=";"; echo "${LUA_PATH_PARTS[*]}")

  declare -a LUA_CPATH_PARTS=(
    "./?.so"
    "$HOME/.luarocks/lib/lua/$1/?.so"
    "/usr/local/lib/lua/$1/?.so"
    "/usr/lib/lua/$1/?.so"
    "/usr/lib/lua/$1/loadall.so"
  )
  GENERATED_LUA_CPATH=$(IFS=";"; echo "${LUA_CPATH_PARTS[*]}")
}

_generate_lua_path_ "5.4"
export LUA_PATH_5_4="$GENERATED_LUA_PATH"
export LUA_CPATH_5_4="$GENERATED_LUA_CPATH"

_generate_lua_path_ "5.3"
export LUA_PATH_5_3="$GENERATED_LUA_PATH"
export LUA_CPATH_5_3="$GENERATED_LUA_CPATH"

_generate_lua_path_ "5.2"
export LUA_PATH_5_2="$GENERATED_LUA_PATH"
export LUA_CPATH_5_2="$GENERATED_LUA_CPATH"

_generate_lua_path_ "5.1"
export LUA_PATH="$GENERATED_LUA_PATH"
export LUA_CPATH="$GENERATED_LUA_CPATH"

# ------------------------------------------------------------------------------
# Hooks
# ------------------------------------------------------------------------------

function on_cd() {
  (python3 $HOME/dots/nvim/onshellcd.py &)
}

chpwd_functions=(${chpwd_functions[@]} "on_cd")

# ------------------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------------------

alias aur='git pull && makepkg -si'
alias single='~/.screenlayout/single.sh'
alias double='~/.screenlayout/double.sh'
alias testwm='Xephyr -br -ac -noreset -screen 800x600 :1 &; DISPLAY=:1 awesome'

alias lrocks5.1='luarocks --lua-version=5.1 --local'
alias lrocks5.2='luarocks --lua-version=5.2 --local'
alias lrocks5.3='luarocks --lua-version=5.3 --local'
alias lrocks5.4='luarocks --lua-version=5.4 --local'
compdef lrocks5.1='luarocks'
compdef lrocks5.2='luarocks'
compdef lrocks5.3='luarocks'
compdef lrocks5.4='luarocks'

alias loverocks='luarocks --lua-version 5.1 --tree luarocks_modules'
compdef loverocks='luarocks'

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

function ansi() {
  setxkbmap us
  ln -sf ~/dots/.ansi.Xmodmap ~/.Xmodmap
  xmodmap ~/.Xmodmap
}

function hhkb() {
  setxkbmap us
  ln -sf ~/dots/.hhkb.Xmodmap ~/.Xmodmap
  xmodmap ~/.Xmodmap
}

# ------------------------------------------------------------------------------
# Personal vs Work
# ------------------------------------------------------------------------------

if [[ -f $HOME/dots/.zshwork ]]; then
  source $HOME/dots/.zshwork
else
  alias kaos='love ~/repos/kaos-love'

  function erde() {
    ERDE_ROOT="$HOME/repos/erde"

    if [[ $LUA_PATH != *"$ERDE_ROOT"* ]]; then
      LUA_PATH="$ERDE_ROOT/?.lua;$ERDE_ROOT/?/init.lua;$LUA_PATH"
      LUA_PATH_5_2="$ERDE_ROOT/?.lua;$ERDE_ROOT/?/init.lua;$LUA_PATH_5_2"
      LUA_PATH_5_3="$ERDE_ROOT/?.lua;$ERDE_ROOT/?/init.lua;$LUA_PATH_5_3"
      LUA_PATH_5_4="$ERDE_ROOT/?.lua;$ERDE_ROOT/?/init.lua;$LUA_PATH_5_4"
    fi

    $HOME/repos/erde/bin/erde $@
  }
fi
