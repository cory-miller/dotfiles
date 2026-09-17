vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = true

local capabilities = require("blink.cmp").get_lsp_capabilities()
local mason_registry = require("mason-registry")

local function setup_lua_ls()
    vim.lsp.config["lua_ls"] = {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
        capabilities = capabilities,
        settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT",
                },
                diagnostics = {
                    globals = { "vim" },
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                },
                telemetry = { enable = false },
            },
        },
    }

    -- Enable/attach server for current buffer
    vim.lsp.enable("lua_ls")
end

-- Check if lua-language-server is installed via Mason
local pkg_name = "lua-language-server"
if mason_registry.is_installed(pkg_name) then
    setup_lua_ls()
else
    mason_registry.get_package(pkg_name):install():once("closed", function()
        vim.schedule(function()
            setup_lua_ls()
        end)
    end)
end
