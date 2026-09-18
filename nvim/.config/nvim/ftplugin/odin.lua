vim.opt_local.expandtab = false

local capabilities = require("blink.cmp").get_lsp_capabilities()

vim.lsp.config('ols', {
    cmd = { "ols" },
    filetypes = { "odin" },
    root_markers = { "ols.json", ".git" },
    capabilities = capabilities,
    init_options = {
        checker_args = "-strict-style",
    },

    vim.lsp.enable("ols")
})
