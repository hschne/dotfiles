return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      ruby = function(bufnr)
        if vim.g.lazyvim_ruby_formatter == "rubocop" or vim.g.lazyvim_ruby_formatter == "standard" then
          return { "lsp" }
        end
        return { vim.g.lazyvim_ruby_formatter }
      end,
      eruby = { "herb_format" },
      svelte = { "prettier" },
      typescript = { "prettier" },
      javascript = { "prettier" },
    },
    formatters = {
      herb_format = {
        command = vim.fn.expand("~/.local/share/mise/shims/herb-format"),
        stdin = true,
      },
    },
  },
}
