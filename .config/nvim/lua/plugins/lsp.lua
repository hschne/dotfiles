local mise = require("util.mise")

-- stimulus-language-server crashes because @herb-tools/core requires @ruby/prism
-- without declaring it as a dependency. @ruby/prism is installed as its own mise
-- npm tool; expose it via NODE_PATH so the server can resolve the module.
local ruby_prism_node_path = mise.install("npm-ruby-prism", "lib/node_modules")

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "b0o/schemastore.nvim" },
    opts = {
      servers = {
        cssls = { settings = { css = { lint = { unknownAtRules = "ignore" } } } },
        herb_ls = {
          mason = false,
          cmd = { mise.shim("herb-language-server"), "--stdio" },
          filetypes = { "html", "eruby" },
        },
        ruby_lsp = {
          mason = false,
          cmd = { mise.shim("ruby-lsp") },
        },
        rubocop = { enabled = false },
        standardrb = { enabled = false },
        jsonls = {
          settings = {
            json = {
              schemas = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          },
        },
        svelte = {
          mason = false,
          cmd = { mise.shim("svelteserver"), "--stdio" },
        },
        stimulus_ls = {
          mason = false,
          cmd = { "env", "NODE_PATH=" .. ruby_prism_node_path, mise.shim("stimulus-language-server"), "--stdio" },
        },
        stylelint_lsp = {
          mason = false,
          cmd = { mise.shim("stylelint-language-server"), "--stdio" },
        },
        yamlls = {
          mason = false,
          cmd = { mise.shim("yaml-language-server"), "--stdio" },
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
