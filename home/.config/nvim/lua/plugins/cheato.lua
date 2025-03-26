return {
  "hschne/cheato.nvim",
  opts = {
    directory = "~/Documents/Wiki/cheats",
  },
  keys = {
    {
      "<leader>oc",
      "<cmd>Cheato<cr>",
      desc = "Open cheat sheet",
      { silent = true },
    },
  },
}
