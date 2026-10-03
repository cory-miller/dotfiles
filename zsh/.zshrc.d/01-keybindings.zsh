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

# Home / End keys
bindkey '^[[H'  beginning-of-line       # Standard Home
bindkey '^[[F'  end-of-line             # Standard End
bindkey '^[[1~' beginning-of-line       # Alternative Home (tmux / rxvt)
bindkey '^[[4~' end-of-line             # Alternative End (tmux / rxvt)

# Ctrl + Left / Right arrows (Word navigation)
bindkey '^[[1;5D' backward-word         # Ctrl + Left
bindkey '^[[1;5C' forward-word          # Ctrl + Right

# Option/Alt + Left / Right arrows (Alternative word navigation)
bindkey '^[[1;3D' backward-word         # Alt + Left
bindkey '^[[1;3C' forward-word          # Alt + Right

# Delete key
bindkey '^[[3~' delete-char             # Delete key
