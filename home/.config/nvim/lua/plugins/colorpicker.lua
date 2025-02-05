return {
  {
    "ziontee113/color-picker.nvim",
    config = function()
      require("color-picker").setup({
        ["icons"] = { ".", "|" },
      })
    end,
    keys = {
      { "<leader>p", "<cmd>PickColor<cr>", desc = "Color Picker" },
    },
  },
}
