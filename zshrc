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
# BINDINGS
# -------------------------------------------------------------------

bindkey '^F' autosuggest-accept


# -------------------------------------------------------------------
# ALIASES
# -------------------------------------------------------------------

alias v='vifm'
alias l='ls -1 --color=auto --group-directories-first'
alias vi='nvim'
alias vim='nvim'
alias wiki='nvim -c :VimwikiIndex'
