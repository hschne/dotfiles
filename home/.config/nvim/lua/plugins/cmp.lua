return {
  "hrsh7th/nvim-cmp",
  -- Luasnips is added last to the completion sources, hence it has priority below buffer.
  -- Reorder it to first position so snippets take precedence over LSP and Buffer.
  --
  -- See https://www.lazyvim.org/plugins/coding#nvim-cmp-1
  opts = function(_, opts)
    local sources = opts.sources
    table.remove(sources, sources.getn)
    table.insert(sources, 1, {
      name = "luasnip",
      group_index = 1,
    })
  end,
}
