return {
    -- Fuzzy Finder
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live Grep (text search)" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Find Buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>",  desc = "Search Help" },
        },
        opts = {
            pickers = {
                find_files = {
                    file_ignore_patterns = { ".git", "node_modules" },
                    hidden = true,
                    no_ignore = true,
                },
            },
        },
    },
    -- File Tree Navigation
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys = {
            { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle File Explorer" },
            { "<leader>E", "<cmd>NvimTreeFocus<cr>",  desc = "Focus File Explorer" },
        },
        opts = {
            filters = { dotfiles = false, git_ignored = true },
            renderer = { group_empty = true },
            update_focused_file = { enable = true, update_root = false },
            view = { width = 30 },
        },
    },
}
