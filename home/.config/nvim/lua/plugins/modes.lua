return {
  {
    "mvllow/modes.nvim",
    config = function()
      require("modes").setup({
        colors = {
          copy = "#ff9e64",
          delete = "#f7768e",
          insert = "#7dcfff",
          visual = "#bb9af7",
        },
        line_opacity = 0.15,
        set_cursor = true,
        set_cursorline = true,
        set_number = true,
        set_signcolumn = true,
      })
    end,
  },
}
