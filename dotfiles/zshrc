# Sync all git repositories in the current directory
git-sync-all() {
    local root_dir=$(pwd)

    for d in */ ; do
        # Use (N) to avoid errors if no directories exist and check for .git
        if [[ -d "${d}.git" ]]; then
            echo "Updating repository: ${d%/}"
            cd "$root_dir/$d" || continue

            # Determine default branch (main/master/etc)
            local default_branch=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
            
            # Remember state
            local current_branch=$(git branch --show-current)
            local has_changes=$(git status --porcelain)

            # Stash if dirty
            if [[ -n "$has_changes" ]]; then
                echo "  - Stashing changes..."
                git stash -q
            fi

            # Update
            echo "  - Updating $default_branch..."
            git checkout "$default_branch" -q
            git pull origin "$default_branch" -q

            # Restore branch
            if [[ "$current_branch" != "$default_branch" ]]; then
                echo "  - Returning to $current_branch..."
                git checkout "$current_branch" -q
            fi

            # Restore changes
            if [[ -n "$has_changes" ]]; then
                echo "  - Reapplying stashed changes..."
                git stash pop -q
            fi

            echo "  - Done."
            cd "$root_dir"
        fi
    done
}

