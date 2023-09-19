return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      indent = { enable = false }, -- Indent with Treesitter is fucked, use classic Vim instead
      endwise = { enable = true },
    },
  },
  { "RRethy/nvim-treesitter-endwise", dependencies = { "nvim-treesitter/nvim-treesitter" } },
}
