return {
  "hschne/floater.nvim",
  dir = "~/Source/floater.nvim",
  opts = {
    files = {
      "~/Documents/Wiki/lists/*.md",
    },
  },
  keys = {
    {
      "<leader>of",
      "<cmd>Floater<cr>",
      desc = "Open Floater files",
      { silent = true },
    },
  },
}
