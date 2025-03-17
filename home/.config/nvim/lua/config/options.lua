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

-- Function to get the TreeSitter language at a specific line
function get_treesitter_lang_at_line(line_num)
  local buf = vim.api.nvim_get_current_buf()
  local zero_based_line = line_num - 1
  local parser = vim.treesitter.get_parser(buf)

  if not parser then
    return "No parser available for this buffer"
  end

  local line_text = vim.api.nvim_buf_get_lines(buf, zero_based_line, zero_based_line + 1, false)[1] or ""
  local range = { zero_based_line, 0, zero_based_line, #line_text }
  local lang_tree = parser:language_for_range(range)

  if lang_tree then
    return lang_tree:lang()
  else
    return "No language detected at line " .. line_num
  end
end

vim.api.nvim_create_user_command("TSGetLang", function()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  vim.notify("Language at current line: " .. get_treesitter_lang_at_line(current_line))
end, {})

function getVisualSelection()
  local modeInfo = vim.api.nvim_get_mode()
  local mode = modeInfo.mode

  local cursor = vim.api.nvim_win_get_cursor(0)
  local cline, ccol = cursor[1], cursor[2]
  local vline, vcol = vim.fn.line("v"), vim.fn.col("v")

  local sline, scol
  local eline, ecol
  if cline == vline then
    if ccol <= vcol then
      sline, scol = cline, ccol
      eline, ecol = vline, vcol
      scol = scol + 1
    else
      sline, scol = vline, vcol
      eline, ecol = cline, ccol
      ecol = ecol + 1
    end
  elseif cline < vline then
    sline, scol = cline, ccol
    eline, ecol = vline, vcol
    scol = scol + 1
  else
    sline, scol = vline, vcol
    eline, ecol = cline, ccol
    ecol = ecol + 1
  end

  if mode == "V" or mode == "CTRL-V" or mode == "\22" then
    scol = 1
    ecol = nil
  end

  local lines = vim.api.nvim_buf_get_lines(0, sline - 1, eline, 0)
  if #lines == 0 then
    return
  end

  local startText, endText
  if #lines == 1 then
    startText = string.sub(lines[1], scol, ecol)
  else
    startText = string.sub(lines[1], scol)
    endText = string.sub(lines[#lines], 1, ecol)
  end

  local selection = { startText }
  if #lines > 2 then
    vim.list_extend(selection, vim.list_slice(lines, 2, #lines - 1))
  end
  table.insert(selection, endText)

  return selection
end
