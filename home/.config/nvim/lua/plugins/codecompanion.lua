return {
  {
    "olimorris/codecompanion.nvim",
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-lualine/lualine.nvim",
      "nvim-treesitter/nvim-treesitter",
      { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
    },
    init = function()
      require("plugins.codecompanion.notify"):setup()
    end,
    display = {
      action_palette = {
        width = 95,
        height = 10,
        prompt = "Prompt ",
        provider = "telescope",
        opts = {
          show_default_actions = true,
          show_default_prompt_library = false,
        },
      },
    },
    opts = {
      strategies = {
        chat = {
          adapter = "anthropic",
        },
        inline = {
          adapter = "anthropic",
        },
      },
      opts = {
        log_level = "DEBUG",
      },
    },
    keys = {
      { "<leader>C", "", desc = "+codecompanion" },
      { "<leader>Ca", "<cmd>CodeCompanionActions<cr>", desc = "Code Companion Actions", mode = { "n", "v" } },
      { "<C-c><C-c>", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Code Companion Chat Toggle", mode = { "n", "v" } },
      { "<leader>CA", "<cmd>CodeCompanionChat Add<cr>", desc = "Code Companion Chat Add", mode = { "v" } },
    },
  },
}
