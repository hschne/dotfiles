return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      local stylelint = {
        lintCommand = 'stylelint --stdin --stdin-filename ${INPUT} --formatter compact',
        lintIgnoreExitCode = true,
        lintStdin = true,
        lintFormats = {
          '%f: line %l, col %c, %tarning - %m',
          '%f: line %l, col %c, %trror - %m',
        },
        formatCommand = 'stylelint --fix --stdin --stdin-filename ${INPUT}',
        formatStdin = true,
      }
      require('lspconfig').efm.setup {
        cmd = { 'efm-langserver' },
        init_options = {
          documentFormatting = true,
          rename = false,
          hover = false,
          completion = false,
        },
        filetypes = { 'css', 'scss' },
        settings = {
          rootMarkers = { '.git', 'package.json' },
          languages = {
            css = { stylelint },
            scss = { stylelint },
          },
        },
      }
    end

  },
}
