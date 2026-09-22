autoload -Uz compinit
compinit -d "$HOME/.zcompdump"

# Case-insensitive tab completion (a-z matches A-Z)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Interactive completion menu (navigate options with arrow keys)
zstyle ':completion:*' menu select

# Colorize completion listings matching your LS_COLORS
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Group completion results by category with headers
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'

