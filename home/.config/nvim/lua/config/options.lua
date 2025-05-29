-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Better long lines
--
-- See https://agilesysadmin.net/how-to-manage-long-lines-in-vim/
vim.opt.showbreak = "…"

-- Improve swapfiles
vim.opt.swapfile = false
vim.opt.directory = vim.fn.expand("$HOME/.local/share/.nvim/swp/")
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand("$HOME/.local/share/.nvim/undo/")

-- Disable prettier if no config file
vim.g.lazyvim_prettier_needs_config = true

-- Project-dependent ruby formatter. If a standardrb config
-- is present we use standard. Otherwise, Rubocop.
local function ruby_formatter()
  local standardrb_config = vim.fn.findfile(".standard.yml")
  if standardrb_config ~= "" then
    return "standardrb"
  end

  return "rubocop"
end

vim.g.lazyvim_ruby_formatter = ruby_formatter()
