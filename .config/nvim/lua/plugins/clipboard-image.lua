return {
  "dfendr/clipboard-image.nvim",
  opts = {
    default = {
      img_dir_txt = "~/Pictures/Screenshots",
    },
  },
  keys = {
    {
      "<leader>pi",
      "<cmd>PasteImg<cr>",
      desc = "Paste Image from Clipboard",
      { silent = true },
    },
  },
}
