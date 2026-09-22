if [[ -d "$HOME/.zshrc.d" ]]; then
    for file in "$HOME/.zshrc.d/"*.zsh(N); do
        source "$file"
    done
fi

if [[ -f "$HOME/.zshrc.local" ]]; then
    source "$HOME/.zshrc.local"
fi

if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

