# -------------------------------------------------------------------
# SETTINGS
# -------------------------------------------------------------------

# History
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

# Options
setopt appendhistory autocd extendedglob nomatch notify
unsetopt beep

# Vim bindings
bindkey -v

# Starship prompt
eval "$(starship init zsh)"


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
