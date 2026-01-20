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

vim.g.root_spec = { "cwd" }

-- Disable prettier if no config file
vim.g.lazyvim_prettier_needs_config = true
vim.g.lazyvim_eslint_auto_format = false

-- Project-dependent ruby formatter. If a standardrb config
-- is present we use standard. Otherwise, Rubocop.
local function ruby_formatter()
  local rubocop_config = vim.fn.findfile(".rubocop.yml")
  if rubocop_config ~= "" then
    return "rubocop"
  end

  return "standardrb"
end

vim.g.lazyvim_ruby_formatter = ruby_formatter()

-- Workaround for LSP Diagnostic issues with Ruby/Prism. Saving now refreshes diagnostics
vim.lsp.handlers["textDocument/diagnostic"] = function(err, result, ctx)
  if result == nil then
    result = { kind = "full", items = {} }
  end
  return require("vim.lsp.diagnostic").on_diagnostic(err, result, ctx)
end
