return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = { mason = false },
        svelte = { mason = false },
        stimulus_ls = { mason = false },
        stylelint_lsp = { mason = false, cmd = { "stylelint-language-server", "--stdio" } },
        yamlls = { mason = false },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {},
    },
  },
}
