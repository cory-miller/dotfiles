return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup({
            -- Pre-install parsers for Go, Odin, and Lua
            ensure_installed = {
                "go",
                "gomod",
                "gowork",
                "gotmpl",
                "odin",
                "lua",
                "vim",
                "vimdoc",
                "markdown",
            },
            auto_install = true,
            highlight = { enable = true },
            indent = { enable = true },
        })
    end,
}
