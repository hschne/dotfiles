return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      ruby = function(bufnr)
        if vim.g.lazyvim_ruby_formatter == "rubocop" or vim.g.lazyvim_ruby_formatter == "standardrb" then
          return { "lsp" }
        end
        return { vim.g.lazyvim_ruby_formatter }
      end,
      eruby = { "herb_format" },
    },
    formatters = {
      herb_format = {
        command = "herb-format",
        stdin = true,
      },
    },
  },
}
