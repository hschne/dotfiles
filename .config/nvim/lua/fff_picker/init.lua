--- *fff_picker.nvim* Snacks picker frontend for fff.nvim
--- *FffPicker*
---
--- Uses fff.nvim for ranked file and content search and Snacks for rendering,
--- preview, and navigation.

local FffPicker = {}
local H = {}

FffPicker.config = {
  prompt = "> ",
  max_results = 100,
  wait_for_index_ms = 10000,
  grep_modes = { "plain", "regex", "fuzzy" },
  files = {},
  grep = {},
}

---@param opts? table
function FffPicker.setup(opts)
  FffPicker.config = vim.tbl_deep_extend("force", FffPicker.config, opts or {})
  H.validate_grep_modes(FffPicker.config.grep_modes)
end

---@param opts? table
function FffPicker.find_files(opts)
  opts = H.options("files", opts)

  return Snacks.picker.pick(vim.tbl_deep_extend("force", {
    source = "fff_files",
    title = "Files",
    prompt = FffPicker.config.prompt,
    live = true,
    show_empty = true,
    finder = function(picker_opts, ctx)
      return H.find_files(ctx.filter.search, picker_opts)
    end,
    format = "file",
    preview = "file",
    matcher = { sort = false },
    sort = { fields = { "idx" } },
    confirm = function(picker, item, action)
      H.confirm("files", picker, item, action)
    end,
  }, opts))
end

---@param opts? table
function FffPicker.live_grep(opts)
  opts = H.options("grep", opts)
  opts.grep_modes = opts.grep_modes or FffPicker.config.grep_modes
  H.validate_grep_modes(opts.grep_modes)
  opts.fff_mode = opts.fff_mode or opts.grep_modes[1]

  return Snacks.picker.pick(vim.tbl_deep_extend("force", {
    source = "fff_grep",
    title = "Grep",
    prompt = FffPicker.config.prompt,
    live = true,
    show_empty = true,
    finder = function(picker_opts, ctx)
      return H.grep(ctx.filter.search, picker_opts)
    end,
    format = "file",
    preview = "file",
    matcher = { sort = false },
    sort = { fields = { "idx" } },
    confirm = function(picker, item, action)
      H.confirm("grep", picker, item, action)
    end,
    actions = {
      cycle_fff_mode = function(picker)
        H.cycle_grep_mode(picker)
      end,
    },
    win = {
      input = {
        keys = {
          ["<S-Tab>"] = { "cycle_fff_mode", mode = { "i", "n" }, desc = "Cycle grep mode" },
        },
      },
      list = {
        keys = {
          ["<S-Tab>"] = { "cycle_fff_mode", mode = { "n", "x" }, desc = "Cycle grep mode" },
        },
      },
    },
  }, opts))
end

---@param opts? table
function FffPicker.grep_word(opts)
  opts = vim.tbl_deep_extend("force", {
    search = function(picker)
      return picker:word()
    end,
  }, opts or {})

  return FffPicker.live_grep(opts)
end

---@param path string
---@param opts? table
function FffPicker.find_files_in_dir(path, opts)
  vim.validate("path", path, "string")
  return FffPicker.find_files(vim.tbl_deep_extend("force", { cwd = path }, opts or {}))
end

---@param kind "files"|"grep"
---@param opts? table
---@return table
function H.options(kind, opts)
  return vim.tbl_deep_extend("force", vim.deepcopy(FffPicker.config[kind]), opts or {})
end

---@param modes table
function H.validate_grep_modes(modes)
  local valid = { plain = true, regex = true, fuzzy = true }
  if type(modes) ~= "table" or #modes == 0 then
    error("fff_picker: grep_modes must not be empty")
  end

  for _, mode in ipairs(modes) do
    if not valid[mode] then
      error("fff_picker: invalid grep mode " .. vim.inspect(mode))
    end
  end
end

---@param path string
---@return string
function H.normalize(path)
  return vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
end

---@param path string
---@param cwd string
---@return string
function H.absolute_path(path, cwd)
  if path:match("^/") or path:match("^%a:[/\\]") then
    return vim.fs.normalize(path)
  end

  return vim.fs.normalize(cwd .. "/" .. path)
end

---@param cwd string
---@return string?
function H.current_file(cwd)
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    return nil
  end

  path = H.normalize(path)
  cwd = H.normalize(cwd):gsub("/$", "")
  local prefix = cwd .. "/"

  return vim.startswith(path, prefix) and path:sub(#prefix + 1) or nil
end

---@param status? string
---@return string?
function H.git_status(status)
  return ({
    untracked = "??",
    unknown = "??",
    ignored = "!!",
    modified = " M",
    deleted = " D",
    renamed = " R",
    staged_new = "A ",
    staged_modified = "M ",
    staged_deleted = "D ",
  })[status]
end

---@return boolean
function H.ensure_picker()
  local picker = require("fff.file_picker")
  return picker.is_initialized() or picker.setup()
end

---@param query string
---@param opts table
---@return table[]
function H.find_files(query, opts)
  if not H.ensure_picker() then
    return {}
  end

  local cwd = H.normalize(opts.cwd or vim.uv.cwd())
  local result = require("fff").file_search(query or "", {
    cwd = cwd,
    current_file = H.current_file(cwd),
    max_results = opts.max_results or FffPicker.config.max_results,
    wait_for_index_ms = opts.wait_for_index_ms or FffPicker.config.wait_for_index_ms,
  })
  local items = {}

  for index, item in ipairs(result.items or {}) do
    local relative_path = item.relative_path or item.path or item.name
    if relative_path and not item.is_dir and item.type ~= "directory" then
      items[#items + 1] = {
        idx = index,
        text = relative_path,
        file = H.absolute_path(relative_path, cwd),
        status = H.git_status(item.git_status),
        fff_path = relative_path,
      }
    end
  end

  return items
end

---@param ranges? table[]
---@return integer[]?
function H.match_positions(ranges)
  if not ranges then
    return nil
  end

  local positions = {}
  for _, range in ipairs(ranges) do
    for column = (range[1] or 0) + 1, range[2] or 0 do
      positions[#positions + 1] = column
    end
  end

  return #positions > 0 and positions or nil
end

---@param query string
---@param opts table
---@return table[]
function H.grep(query, opts)
  if not query or query == "" or not H.ensure_picker() then
    return {}
  end

  local cwd = H.normalize(opts.cwd or vim.uv.cwd())
  local result = require("fff").content_search(query, {
    cwd = cwd,
    mode = opts.fff_mode,
    page_size = opts.max_results or FffPicker.config.max_results,
    wait_for_index_ms = opts.wait_for_index_ms or FffPicker.config.wait_for_index_ms,
  })
  local items = {}

  for index, item in ipairs(result.items or {}) do
    local relative_path = item.relative_path or item.path or item.name
    if relative_path then
      items[#items + 1] = {
        idx = index,
        text = ("%s:%d:%d:%s"):format(
          relative_path,
          item.line_number or 0,
          (item.col or 0) + 1,
          item.line_content or ""
        ),
        file = H.absolute_path(relative_path, cwd),
        pos = { item.line_number or 0, item.col or 0 },
        line = item.line_content,
        positions = H.match_positions(item.match_ranges),
        status = H.git_status(item.git_status),
        fff_path = relative_path,
      }
    end
  end

  return items
end

---@param kind "files"|"grep"
---@param picker table
---@param item? table
---@param action table
function H.confirm(kind, picker, item, action)
  if item then
    local query = picker.input.filter.search or ""
    local fuzzy = require("fff.fuzzy")

    if kind == "grep" then
      pcall(fuzzy.track_grep_query, query)
    else
      pcall(fuzzy.track_query_completion, query, item.fff_path)
    end
  end

  require("snacks.picker.actions").jump(picker, item, action)
end

---@param picker table
function H.cycle_grep_mode(picker)
  local modes = picker.opts.grep_modes
  local current = picker.opts.fff_mode
  local index = 1

  for i, mode in ipairs(modes) do
    if mode == current then
      index = i
      break
    end
  end

  picker.opts.fff_mode = modes[index % #modes + 1]
  vim.notify("FFF grep mode: " .. picker.opts.fff_mode)
  picker:refresh()
end

return FffPicker
