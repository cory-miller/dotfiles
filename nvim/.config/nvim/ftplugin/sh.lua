local capabilities = require("blink.cmp").get_lsp_capabilities()
local mason_registry = require("mason-registry")

local function setup_bashls()
    vim.lsp.config("bashls", {
        cmd = { "bash-language-server", "start" },
        filetypes = { "sh", "bash", "zsh" },
        root_markers = { ".git", ".bashrc", ".zshrc" },
        capabilities = capabilities,
        settings = {
            bashIde = {
                globPattern = "*@(.sh|.inc|.bash|.command|.zsh)",
                -- Enable shellcheck integration inside the language server
                enableSourceErrorDiagnostics = true,
            },
        },
    })

    vim.lsp.enable("bashls")
end

local required_pkgs = { "bash-language-server", "shellcheck", "shfmt" }

for _, pkg_name in ipairs(required_pkgs) do
    if not mason_registry.is_installed(pkg_name) then
        mason_registry.get_package(pkg_name):install()
    end
end

if mason_registry.is_installed("bash-language-server") then
    setup_bashls()
else
    mason_registry.get_package("bash-language-server"):install():once("closed", function()
        vim.schedule(setup_bashls)
    end)
end
