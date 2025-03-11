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

-- Expand cc command
-- Add filetype for todo
vim.filetype.add({
  filename = {
    ["todo.txt"] = "todotxt",
    ["todo.done.txt"] = "todotxt",
    ["todo-meister.txt"] = "todotxt",
    ["todo-meister.done.txt"] = "todotxt",
  },
})

-- This is a dummy, test this out with silicon nvim
function get_selected_code_block_language()
  -- Get visual selection range
  local start_row, start_col = unpack(vim.fn.getpos("'<")[1][3])
  local end_row, end_col = unpack(vim.fn.getpos("'>")[1][3])
  start_row = start_row - 1 -- Convert to 0-indexed
  end_row = end_row - 1 -- Convert to 0-indexed

  -- Get current buffer and parser
  local bufnr = vim.api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(bufnr, "markdown")
  local tree = parser:parse()[1]
  local root = tree:root()

  -- Find the node at selection position
  local node = root:named_descendant_for_range(start_row, start_col, end_row, end_col)

  -- Walk up the tree to find code block
  while node ~= nil and node:type() ~= "fenced_code_block" do
    node = node:parent()
  end

  -- If we found a code block, extract language
  if node ~= nil and node:type() == "fenced_code_block" then
    -- Get the info string (language identifier)
    for child in node:iter_children() do
      if child:type() == "info_string" then
        local language = vim.treesitter.get_node_text(child, bufnr)
        return language
      end
    end
  end

  return nil
end
