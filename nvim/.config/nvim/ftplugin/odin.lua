vim.opt_local.expandtab = false

local capabilities = require("blink.cmp").get_lsp_capabilities()

vim.lsp.config('ols', {
    capabilities = capabilities,
    init_options = {
        checker_args = "-strict-style",
    },
})
