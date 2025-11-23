-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

vim.keymap.set("n", "<leader>yn", '<cmd>let @+ = expand("%:t")<cr>', { desc = "Copy file name", silent = true })
vim.keymap.set("n", "<leader>yr", '<cmd>let @+ = expand("%:.")<cr>', { desc = "Copy relative path", silent = true })
vim.keymap.set("n", "<leader>ya", '<cmd>let @+ = expand("%:p")<cr>', { desc = "Copy absolute path", silent = true })

vim.keymap.set("v", "<leader>xy", "<cmd>lua print(vim.inspect(getVisualSelection()))<Cr>")

-- Split line at cursor position
vim.keymap.set("n", "<leader><CR>", "i<CR><Esc>", { desc = "Split line at cursor" })
