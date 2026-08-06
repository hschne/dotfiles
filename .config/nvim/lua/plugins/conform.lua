local mise = require("util.mise")

return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      ruby = { "lsp" },
      eruby = { "herb_format" },
      svelte = { "prettier" },
      typescript = { "prettier" },
      javascript = { "prettier" },
    },
    formatters = {
      herb_format = {
        command = mise.shim("herb-format"),
        stdin = true,
      },
    },
  },
}
