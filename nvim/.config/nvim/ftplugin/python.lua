local capabilities = require("blink.cmp").get_lsp_capabilities()
local mason_registry = require("mason-registry")

local function setup_pyright()
    vim.lsp.config["pyright"] = {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
        capabilities = capabilities,
        settings = {
            python = {
                analysis = {
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                    diagnosticMode = "workspace",
                },
            },
        },
    }

    vim.lsp.enable("pyright")
end

local pkg_name = "pyright"
if mason_registry.is_installed(pkg_name) then
    setup_pyright()
else
    mason_registry.get_package(pkg_name):install():once("closed", function()
        vim.schedule(function()
            setup_pyright()
        end)
    end)
end
