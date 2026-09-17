vim.opt_local.expandtab = false

local capabilities = require("blink.cmp").get_lsp_capabilities()
local mason_registry = require("mason-registry")

local function setup_gopls()
    vim.lsp.config('gopls', {
        capabilities = capabilities,
        settings = {
            gopls = {
                analyses = { unusedparams = true },
                staticcheck = true,
            },
        },
    })
end

local pkg_name = "gopls"

if mason_registry.is_installed(pkg_name) then
    setup_gopls()
else
    mason_registry.get_package(pkg_name):install():once("closed", function()
        vim.schedule(function()
            setup_gopls()
            vim.cmd("LspStart gopls")
        end)
    end)
end
