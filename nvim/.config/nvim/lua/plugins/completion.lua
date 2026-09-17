return {
    "saghen/blink.cmp",
    version = "*",
    opts = {
        keymap = {
            preset = "default",
            ["<C-k>"] = { "select_prev", "fallback" },
            ["<C-j>"] = { "select_next", "fallback" },
            ["<C-b>"] = { "scroll_documentation_up", "fallback" },
            ["<C-f>"] = { "scroll_documentation_down", "fallback" },
            ["<C-Space>"] = { "show", "show_documentation", "fallback" },
            ["<CR>"] = { "accept", "fallback" },
            ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
            ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
        },

        sources = {
            default = { "lsp", "path", "snippets", "buffer" },
        },

        completion = {
            documentation = { auto_show = true, auto_show_delay_ms = 200 },
            menu = { draw = { columns = { { "label", "label_description", gap = 1 }, { "kind" } } } },
        },

        snippets = { preset = "default" },
    },
}
