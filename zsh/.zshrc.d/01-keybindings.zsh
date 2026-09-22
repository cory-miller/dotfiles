# Ensure Emacs keybindings (enables Ctrl+R, Ctrl+A, Ctrl+E)
bindkey -e

# Ctrl+R for interactive reverse history search
bindkey '^R' history-incremental-search-backward

# Up/Down arrows search history matching current typed prefix
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey '^[[A' up-line-or-beginning-search   # Up arrow
bindkey '^[[B' down-line-or-beginning-search # Down arrow

