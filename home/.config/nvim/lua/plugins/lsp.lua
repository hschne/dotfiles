local formatter = vim.g.lazyvim_ruby_formatter

vim.lsp.config("herb_ls", {
  filetypes = { "html", "eruby" },
})
vim.lsp.enable("herb_ls")

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "b0o/schemastore.nvim" },
    opts = {
      servers = {
        cssls = { settings = { css = { lint = { unknownAtRules = "ignore" } } } },
        erb_formatter = {
          mason = false,
          enabled = false,
        },
        ruby_lsp = {
          mason = false,
          cmd = { vim.fn.expand("~/.local/share/mise/shims/ruby-lsp") },
        },
        rubocop = {
          mason = false,
          enabled = formatter == "rubocop",
          cmd = { vim.fn.expand("~/.local/share/mise/shims/rubocop"), "--lsp" },
        },
        standardrb = {
          mason = false,
          enabled = formatter == "standardrb",
          cmd = { vim.fn.expand("~/.local/share/mise/shims/standardrb"), "--lsp" },
        },
        jsonls = {
          settings = {
            json = {
              schemas = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          },
        },
        yamlls = {
          settings = {
            yaml = {
              schemaStore = {
                enable = false,
                url = "",
              },
              schemas = require("schemastore").yaml.schemas({
                extra = {
                  {
                    name = "Honeybadger",
                    description = "Honeybadger configuration",
                    fileMatch = { "honeybadger.yml" },
                    url = "https://www.rubyschema.org/honeybadger.json",
                  },
                  {
                    name = "i18n-tasks",
                    description = "i18n-tasks configuration",
                    fileMatch = { "i18n-tasks.yml" },
                    url = "https://www.rubyschema.org/i18n-tasks.json",
                  },
                  {
                    name = "Lefthook",
                    description = "Lefthook configuration",
                    fileMatch = { "lefthook.yml" },
                    url = "https://www.rubyschema.org/lefthook.json",
                  },
                  {
                    name = "Mongoid",
                    description = "Mongoid configuration",
                    fileMatch = { "mongoid.yml" },
                    url = "https://www.rubyschema.org/mongoid.json",
                  },
                  {
                    name = "PgHero",
                    description = "PgHero configuration",
                    fileMatch = { "pghero.yml" },
                    url = "https://www.rubyschema.org/pghero.json",
                  },
                  {
                    name = "RorVsWild",
                    description = "RorVsWild configuration",
                    fileMatch = { "rorvswild.yml" },
                    url = "https://www.rubyschema.org/rorvswild.json",
                  },
                  {
                    name = "Rubocop",
                    description = "Rubocop configuration",
                    fileMatch = { ".rubocop.yml" },
                    url = "https://www.rubyschema.org/rubocop.json",
                  },
                  {
                    name = "Scout APM",
                    description = "Scout APM configuration",
                    fileMatch = { "scout_apm.yml" },
                    url = "https://www.rubyschema.org/scout_apm.json",
                  },
                  {
                    name = "Shoryuken",
                    description = "Shoryuken configuration",
                    fileMatch = { "shoryuken.yml" },
                    url = "https://www.rubyschema.org/shoryuken.json",
                  },
                  {
                    name = "Sidekiq",
                    description = "Sidekiq configuration",
                    fileMatch = { "sidekiq.yml" },
                    url = "https://www.rubyschema.org/sidekiq.json",
                  },
                  {
                    name = "Standard",
                    description = "Standard Ruby configuration",
                    fileMatch = { ".standard.yml" },
                    url = "https://www.rubyschema.org/standard.json",
                  },
                  {
                    name = "Vite Ruby",
                    description = "Vite Ruby configuration",
                    fileMatch = { "vite.yml" },
                    url = "https://www.rubyschema.org/vite.json",
                  },
                  {
                    name = "Rails i18n locale",
                    description = "Rails i18n locale",
                    fileMatch = { "locale/*.yml" },
                    url = "https://www.rubyschema.org/i18n/locale.json",
                  },
                  {
                    name = "Kamal",
                    description = "Kamal deployment configuration",
                    fileMatch = { "config/deploy.yml" },
                    url = "https://www.rubyschema.org/kamal/deploy.json",
                  },
                  {
                    name = "Packwerk",
                    description = "Packwerk package configuration",
                    fileMatch = { "package.yml" },
                    url = "https://www.rubyschema.org/packwerk/package.json",
                  },
                  {
                    name = "Rails Cable",
                    description = "Rails cable configuration",
                    fileMatch = { "cable.yml" },
                    url = "https://www.rubyschema.org/rails/cable.json",
                  },
                  {
                    name = "Rails Cache",
                    description = "Rails cache configuration",
                    fileMatch = { "cache.yml" },
                    url = "https://www.rubyschema.org/rails/cache.json",
                  },
                  {
                    name = "Rails Database",
                    description = "Rails database configuration",
                    fileMatch = { "database.yml" },
                    url = "https://www.rubyschema.org/rails/database.json",
                  },
                  {
                    name = "Rails Queue",
                    description = "Rails queue configuration",
                    fileMatch = { "queue.yml" },
                    url = "https://www.rubyschema.org/rails/queue.json",
                  },
                  {
                    name = "Rails Recurring",
                    description = "Rails recurring tasks configuration",
                    fileMatch = { "recurring.yml" },
                    url = "https://www.rubyschema.org/rails/recurring.json",
                  },
                  {
                    name = "Rails Storage",
                    description = "Rails storage configuration",
                    fileMatch = { "storage.yml" },
                    url = "https://www.rubyschema.org/rails/storage.json",
                  },
                },
              }),
            },
          },
        },
      },
    },
  },
}
