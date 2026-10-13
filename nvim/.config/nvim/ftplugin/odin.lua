vim.opt_local.expandtab = false

local capabilities = require("blink.cmp").get_lsp_capabilities()
local mason_registry = require("mason-registry")

local function setup_ols()
    vim.lsp.config('ols', {
        cmd = { "ols" },
        filetypes = { "odin" },
        root_markers = { "ols.json", ".git" },
        capabilities = capabilities,
        init_options = {
            checker_args = "-strict-style",
        },

    })

    vim.lsp.enable("ols")
end

local pkg_name = "ols"
if mason_registry.is_installed(pkg_name) then
    setup_ols()
else
    mason_registry.get_package(pkg_name):install():once("closed", function()
        vim.schedule(setup_ols)
    end)
end
