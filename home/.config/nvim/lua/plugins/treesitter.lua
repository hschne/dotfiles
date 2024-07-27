return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "scss",
      })
      -- Use markdown parser for vimwiki files
      vim.treesitter.language.register("markdown", "vimwiki")
    end,
    config = function()
      local opt = vim.opt
      opt.foldmethod = "expr"
      opt.foldexpr = "nvim_treesitter#foldexpr()"
      opt.foldlevel = 99
    end,
  },
}
