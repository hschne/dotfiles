-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--

-- Better long lines
--
-- See https://agilesysadmin.net/how-to-manage-long-lines-in-vim/
vim.opt.showbreak = "…"

-- Improve swapfiles
vim.opt.swapfile = false
vim.opt.directory = vim.fn.expand("~/.local/share/nvim/swp")
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand("~/.local/share/nvim/undo")
-- Configure Vimwiki
vim.g.vimwiki_list = {
  {
    path = "~/Documents/wiki",
    syntax = "markdown",
    index = "home",
    ext = ".md",
    auto_diary_index = 1,
  },
}
vim.g.vimwiki_global_ext = 1
