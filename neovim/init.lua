vim.opt.number = true         	-- Show absolute line number on the current line
vim.opt.relativenumber = true 	-- Show relative line numbers on all other lines

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.g.mapleader = " " 		-- See <Leader> below. Default is '\'.

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0 		-- Set to 0 to default to tabstop value

-- Show error details in a floating window on hover
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, { desc = "Show line error" })

-- Jump between syntax errors
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Previous error" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Next error" })

-- See all file errors inside a list window
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, { desc = "Open error list" })

-- Visit the project page for the latest installation instructions
-- https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        -- Fuzzy finder
        "https://github.com/junegunn/fzf.vim",
        dependencies = {
            "https://github.com/junegunn/fzf",
        },
        keys = {
            { "<Leader><Leader>", "<Cmd>Files<CR>", desc = "Find files" },
            { "<Leader>,", "<Cmd>Buffers<CR>", desc = "Find buffers" },
            { "<Leader>/", "<Cmd>Rg<CR>", desc = "Search project" },
        },
    },
    {
        -- File explorer
        "https://github.com/stevearc/oil.nvim",
        config = function()
            require("oil").setup()
        end,
        keys = {
            { "-", "<Cmd>Oil<CR>", desc = "Browse files from here" },
        },
    },
    {
        -- Automatically determine indent settings
        "https://github.com/tpope/vim-sleuth",
        event = { "BufReadPost", "BufNewFile" }, -- Load after your file content
    },
    {
        -- LSP
        "https://github.com/VonHeikemen/lsp-zero.nvim",
        dependencies = {
            "https://github.com/williamboman/mason.nvim",
            "https://github.com/williamboman/mason-lspconfig.nvim",
            "https://github.com/neovim/nvim-lspconfig",
            "https://github.com/hrsh7th/cmp-nvim-lsp",
            "https://github.com/hrsh7th/nvim-cmp",
            "https://github.com/L3MON4D3/LuaSnip",
        },
        config = function()
            local lsp_zero = require('lsp-zero')

            lsp_zero.on_attach(function(client, bufnr)
                lsp_zero.default_keymaps({buffer = bufnr})
            end)

            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    -- See https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
                    -- "gopls",         -- Go
                    "ols",              -- Odin
                    -- "pyright",       -- Python
                    -- "rust_analyzer", -- Rust
                },
                handlers = {
                    lsp_zero.default_setup,
                },
            })
        end,
    },
})

