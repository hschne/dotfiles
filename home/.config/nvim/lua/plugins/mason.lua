return {
  {
    "williamboman/mason.nvim",
    -- Pin version for workaroud
    -- https://github.com/LazyVim/LazyVim/issues/6039#issuecomment-2856227817
    version = "^1.0.0",
    opts = {
      ensure_installed = {
        "bash-language-server",
        "css-lsp",
        "docker-compose-language-service",
        "dockerfile-language-server",
        "emmet-ls",
        "eslint-lsp",
        "html-lsp",
        "json-lsp",
        "stylelint-lsp",
        "shellcheck",
        "sqlfmt",
        "stylua",
        "yaml-language-server",
      },
    },
  },
  { "mason-org/mason-lspconfig.nvim", version = "^1.0.0" },
}
