vim.opt_local.expandtab = false

local capabilities = require("blink.cmp").get_lsp_capabilities()
local mason_registry = require("mason-registry")

local function setup_gopls()
    vim.lsp.config('gopls', {
        cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        root_markers = { "go.work", "go.mod", ".git" },
        capabilities = capabilities,
        settings = {
            gopls = {
                analyses = { unusedparams = true },
                staticcheck = true,
            },
        },
    })

    vim.lsp.enable("gopls")
end

local pkg_name = "gopls"
if mason_registry.is_installed(pkg_name) then
    setup_gopls()
else
    mason_registry.get_package(pkg_name):install():once("closed", function()
        vim.schedule(setup_gopls)
    end)
end
