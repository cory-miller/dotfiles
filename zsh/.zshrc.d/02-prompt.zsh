# Enable VCS (version control system) info execution
autoload -Uz vcs_info
autoload -Uz colors && colors

# Execute vcs_info before every prompt render
precmd() { vcs_info }

# Enable prompt substitution
setopt PROMPT_SUBST

# %b = branch name, %u = unstaged changes (*), %c = staged changes (+)
zstyle ':vcs_info:git:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr '*'
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats '%F{yellow}(%b%u%c)%f '

PROMPT='%F{cyan}%1~%f ${vcs_info_msg_0_}%# '

