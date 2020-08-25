# -------------------------------------------------------------------
# SETTINGS
# -------------------------------------------------------------------

# History
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

# Emacs Bindings
bindkey -e

# Options
setopt appendhistory autocd extendedglob nomatch notify
unsetopt beep

# -------------------------------------------------------------------
# COMPLETION
# -------------------------------------------------------------------

zstyle ':completion:*' completer _complete _ignored _approximate
zstyle ':completion:*' matcher-list '' '' '' ''
zstyle :compinstall filename '/home/bsuth/.zshrc'

autoload -Uz compinit
compinit

# -------------------------------------------------------------------
# ZINIT
# -------------------------------------------------------------------

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

# -------------------------------------------------------------------
# SPACESHIP-PROMPT
# -------------------------------------------------------------------

SPACESHIP_PROMPT_ORDER=(
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

# -------------------------------------------------------------------
# FZF
# -------------------------------------------------------------------

export FZF_DEFAULT_COMMAND='rg --files'

### PROCESS
# mnemonic: [K]ill [P]rocess
# show output of "ps -ef", use [tab] to select one or multiple entries
# press [enter] to kill selected processes and go back to the process list.
# or press [escape] to go back to the process list. Press [escape] twice to exit completely.

function kp() {
	local pid=$(ps -ef | sed 1d | eval "fzf ${FZF_DEFAULT_OPTS} -m --header='[kill:process]'" | awk '{print $2}')

	if [ "x$pid" != "x" ]
	then
	  echo $pid | xargs kill -${1:-9}
	  kp
	fi
}

# -------------------------------------------------------------------
# ALIASES
# -------------------------------------------------------------------
alias v='vifm'
alias l='ls -1 --color=auto --group-directories-first'
alias vi='nvim'
alias vim='nvim'
alias wiki='nvim -c :VimwikiIndex'
alias single='xrandr --output eDP1 --primary --mode 1600x900 --pos 1920x90 --output DP2-2 --off'
alias double='xrandr --output DP2-2 --primary --mode 1920x1080 --pos 0x0 --output eDP1 --mode 1600x900 --pos 1920x90'
