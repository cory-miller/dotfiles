local capabilities = require("blink.cmp").get_lsp_capabilities()
local mason_registry = require("mason-registry")

local function get_python_path()
    local venv_path = os.getenv("VIRTUAL_ENV")

    if not venv_path then
        local cwd = vim.fn.getcwd()
        if vim.fn.filereadable(cwd .. "/poetry.lock") == 1 or vim.fn.filereadable(cwd .. "/pyproject.toml") == 1 then
            if vim.fn.executable("poetry") == 1 then
                local handle = io.popen("poetry env info -p 2>/dev/null")
                if handle then
                    local result = handle:read("*a")
                    handle:close()
                    result = vim.trim(result)
                    if #result > 0 and vim.fn.isdirectory(result) == 1 then
                        venv_path = result
                    end
                end
            end
        end
    end

    if not venv_path then
        local cwd = vim.fn.getcwd()
        if vim.fn.isdirectory(cwd .. "/.venv") == 1 then
            venv_path = cwd .. "/.venv"
        elseif vim.fn.isdirectory(cwd .. "/venv") == 1 then
            venv_path = cwd .. "/venv"
        end
    end

    if venv_path then
        return venv_path .. "/bin/python"
    end

    return vim.fn.exepath("python3") or "python"
end

local function setup_pyright()
    local python_executable = get_python_path()

    vim.lsp.config["pyright"] = {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
        capabilities = capabilities,
        settings = {
            python = {
                pythonPath = python_executable,
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
        vim.schedule(setup_pyright)
    end)
end
