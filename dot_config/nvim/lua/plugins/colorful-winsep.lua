return {
  "nvim-zh/colorful-winsep.nvim",
  config = true,
  event = { "WinLeave" },
  opts = {
    border = "single",
    animate = {
      enabled = "false",
    },
    indicator_for_2wins = {
      position = "false",
    },
  },
}
