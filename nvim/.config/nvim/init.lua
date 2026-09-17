-- Leader key to Space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load core options and keymaps
require("config.options")
require("config.keymaps")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugin specifications from lua/plugins/
require("lazy").setup("plugins", {
    change_detection = { notify = false },
})

