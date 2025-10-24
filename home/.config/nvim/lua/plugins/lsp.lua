local formatter = vim.g.lazyvim_ruby_formatter

vim.lsp.config("herb_ls", {
  filetypes = { "html", "eruby" },
})
vim.lsp.enable("herb_ls")

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        cssls = { settings = { css = { lint = { unknownAtRules = "ignore" } } } },
        erb_formatter = {
          mason = false,
          enabled = false,
        },
        ruby_lsp = {
          mason = false,
        },
        rubocop = {
          mason = false,
          enabled = formatter == "rubocop",
        },
        standardrb = {
          mason = false,
          enabled = formatter == "standardrb",
        },
        yamlls = {
          settings = {
            yaml = {
              schemas = {
                ["https://www.rubyschema.org/honeybadger.json"] = "honeybadger.yml",
                ["https://www.rubyschema.org/i18n-tasks.json"] = "i18n-tasks.yml",
                ["https://www.rubyschema.org/lefthook.json"] = "lefthook.yml",
                ["https://www.rubyschema.org/mongoid.json"] = "mongoid.yml",
                ["https://www.rubyschema.org/pghero.json"] = "pghero.yml",
                ["https://www.rubyschema.org/rorvswild.json"] = "rorvswild.yml",
                ["https://www.rubyschema.org/rubocop.json"] = ".rubocop.yml",
                ["https://www.rubyschema.org/scout_apm.json"] = "scout_apm.yml",
                ["https://www.rubyschema.org/shoryuken.json"] = "shoryuken.yml",
                ["https://www.rubyschema.org/sidekiq.json"] = "sidekiq.yml",
                ["https://www.rubyschema.org/standard.json"] = ".standard.yml",
                ["https://www.rubyschema.org/vite.json"] = "vite.yml",
                ["https://www.rubyschema.org/i18n/locale.json"] = "locale/*.yml",
                ["https://www.rubyschema.org/kamal/deploy.json"] = "deploy.yml",
                ["https://www.rubyschema.org/packwerk/package.json"] = "package.yml",
                ["https://www.rubyschema.org/rails/cable.json"] = "cable.yml",
                ["https://www.rubyschema.org/rails/cache.json"] = "cache.yml",
                ["https://www.rubyschema.org/rails/database.json"] = "database.yml",
                ["https://www.rubyschema.org/rails/queue.json"] = "queue.yml",
                ["https://www.rubyschema.org/rails/recurring.json"] = "recurring.yml",
                ["https://www.rubyschema.org/rails/storage.json"] = "storage.yml",
              },
            },
          },
        },
      },
    },
  },
}
