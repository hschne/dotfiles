return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        dockerls = {},
        docker_compose_language_service = {},
        emmet_ls = {},
        eslint = {},
        html = {},
        jsonls = {},
        rome = {},
        rubocop = {},
        solargraph = {},
        yamlls = {},
      },
    },
  },
}
