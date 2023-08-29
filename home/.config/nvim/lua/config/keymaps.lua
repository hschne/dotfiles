-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set(
  "n",
  "<leader>sN",
  require("telescope").extensions.notify.notify,
  { noremap = true, silent = true, desc = "Notifications" }
)

vim.keymap.set(
  "n",
  "<leader>w<leader>c",
  "<cmd>VimwikiToggleListItem<cr>",
  { noremap = true, silent = true, desc = "Complete/Toggle Checklist Item" }
)
