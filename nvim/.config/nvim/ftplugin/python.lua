local capabilities = require("blink.cmp").get_lsp_capabilities()
local mason_registry = require("mason-registry")

local function get_python_path(root_dir)
    local venv = os.getenv("VIRTUAL_ENV")

    if venv and vim.fn.filereadable(vim.fs.joinpath(venv, "bin", "python")) == true then
        return vim.fs.joinpath(venv, "bin", "python")
    end

    if root_dir then
        for _, name in ipairs({ ".venv", "venv", "env" }) do
            local candidate = vim.fs.joinpath(root_dir, name, "bin", "python")
            if vim.fn.filereadable(candidate) == 1 then
                return candidate
            end
        end

        local has_poetry_lock = vim.fn.filereadable(vim.fs.joinpath(root_dir, "poetry.lock")) == 1
        if has_poetry_lock and vim.fn.executable("poetry") == 1 then
            local handle = io.popen(string.format("cd %q && poetry env info -p 2>/dev/null", root_dir))
            if handle then
                local result = handle:read("*a")
                handle:close()
                result = vim.trim(result)
                local poetry_py = vim.fs.joinpath(result, "bin", "python")
                if #result > 0 and vim.fn.filereadable(poetry_py) == 1 then
                    return poetry_py
                end
            end
        end
    end

    return vim.fn.exepath("python3") or "python"
end

local function setup_pyright()
    vim.lsp.config("pyright", {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
        capabilities = capabilities,
        before_init = function(_, config)
            local py_path = get_python_path(config.root_dir)
            config.settings = config.settings or {}
            config.settings.python = config.settings.python or {}
            config.settings.python.pythonPath = py_path
        end,
        settings = {
            python = {
                analysis = {
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                    diagnosticMode = "openFilesOnly",
                },
            },
        },
    })

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
