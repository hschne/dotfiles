local formatter = vim.g.lazyvim_ruby_formatter
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        cssls = { settings = { css = { lint = { unknownAtRules = "ignore" } } } },
        html = {
          filetypes = { "html", "eruby" },
        },
        ruby_lsp = {
          mason = false,
          cmd = { vim.fn.expand("~/.asdf/shims/ruby-lsp") },
        },
        rubocop = {
          mason = false,
          enabled = formatter == "rubocop",
          cmd = { vim.fn.expand("~/.asdf/shims/rubocop"), "--lsp" },
        },
        standardrb = {
          mason = false,
          enabled = formatter == "standardrb",
          cmd = { vim.fn.expand("~/.asdf/shims/standardrb"), "--lsp" },
        },
      },
    },
  },
}
