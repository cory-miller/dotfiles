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
            view = { width = 30 },
            renderer = { group_empty = true },
            filters = { dotfiles = false, git_ignored = true },
        },
    },
}
