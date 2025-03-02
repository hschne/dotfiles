return {
  {
    "olimorris/codecompanion.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    init = function()
      vim.cmd([[cab cc CodeCompanion]])
    end,
    opts = {
      strategies = {
        chat = {
          adapter = "anthropic",
        },
        inline = {
          adapter = "anthropic",
        },
      },
    },
    keys = {
      { "<leader>C", "", desc = "+codecompanion" },
      { "<leader>Ca", "<cmd>CodeCompanionActions<cr>", desc = "Code Companion Actions", mode = { "n", "v" } },
      { "<leader>Cc", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Code Companion Chat Toggle", mode = { "n", "v" } },
      { "<leader>CA", "<cmd>CodeCompanionChat Add<cr>", desc = "Code Companion Chat Add", mode = { "v" } },
    },
  },
}
