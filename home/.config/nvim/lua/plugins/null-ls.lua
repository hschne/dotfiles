return {
  -- NUll LS has been archived, use efm-ls  for now
  {
    'jose-elias-alvarez/null-ls.nvim',
    opts = function(_, opts)
      local nls = require("null-ls")
      table.insert(opts.sources, nls.builtins.formatting.rubocop)
      table.insert(opts.sources, nls.builtins.diagnostics.rubocop)
      table.insert(opts.sources, nls.builtins.formatting.stylelint)
      table.insert(opts.sources, nls.builtins.diagnostics.stylelint)
      table.insert(opts.sources, nls.builtins.diagnostics.shellcheck)
    end,
  }
}
