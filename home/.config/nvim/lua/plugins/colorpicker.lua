return {
  {
    "ziontee113/color-picker.nvim",
    config = function()
      require("color-picker").setup({
        ["icons"] = { ".", "|" },
      })
    end,
    keys = {
      { "<leader>pc", "<cmd>PickColor<cr>", desc = "Color Picker", { silent = true } },
    },
  },
}
