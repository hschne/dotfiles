return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      indent = { enable = false }, -- Indent with Treesitter is fucked, use classic Vim instead
      endwise = { enable = true },
    },
    config = function()
      local opt = vim.opt
      opt.foldmethod = "expr"
      opt.foldexpr = "nvim_treesitter#foldexpr()"
      opt.foldlevel = 99
    end
  },
  { "RRethy/nvim-treesitter-endwise", dependencies = { "nvim-treesitter/nvim-treesitter" } },
}
