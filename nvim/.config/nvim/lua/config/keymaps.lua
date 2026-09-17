local keymap = vim.keymap.set

-- Quick save / quit
keymap("n", "<leader>w", ":w<CR>", { desc = "Save file" })
keymap("n", "<leader>q", ":q<CR>", { desc = "Quit window" })

-- Clear search highlights
keymap("n", "<leader>nh", ":nohlsearch<CR>", { desc = "Clear highlights" })

