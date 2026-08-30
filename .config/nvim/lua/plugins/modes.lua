return {
  {
    "mvllow/modes.nvim",
    -- Later commits use :redraw on mode changes, which breaks Snacks picker input.
    -- See https://github.com/folke/snacks.nvim/issues/2810
    commit = "2badf87",
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
