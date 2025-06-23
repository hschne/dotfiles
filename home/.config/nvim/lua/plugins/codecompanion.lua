return {
  {
    "olimorris/codecompanion.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-lualine/lualine.nvim",
      "nvim-treesitter/nvim-treesitter",
      { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
      "ravitemer/codecompanion-history.nvim",
    },
    init = function()
      require("plugins.codecompanion.notify"):setup()
      vim.g.codecompanion_auto_tool_mode = true
    end,
    opts = {
      display = {
        diff = {
          enabled = false,
        },
        chat = {
          intro_message = "Welcome to CodeCompanion ✨! Press ? for options",
        },
        action_palette = {
          opts = {
            show_default_actions = true,
            show_default_prompt_library = true,
          },
        },
      },
      strategies = {
        chat = {
          adapter = "anthropic",
        },
        inline = {
          adapter = "anthropic",
        },
      },
      extensions = {
        history = {
          enabled = true,
          opts = {
            keymap = "gh",
            save_chat_keymap = "sc",
            auto_save = true,
            expiration_days = 7,
            picker = "fzf-lua",
            picker_keymaps = {
              rename = { n = "r", i = "<M-r>" },
              delete = { n = "d", i = "<M-d>" },
              duplicate = { n = "<C-y>", i = "<C-y>" },
            },
            auto_generate_title = true,
            title_generation_opts = {
              adapter = nil, -- "copilot"
              model = nil, -- "gpt-4o"
              refresh_every_n_prompts = 3, -- e.g., 3 to refresh after every 3rd user prompt
              max_refreshes = 3,
            },
            continue_last_chat = false,
            delete_on_clearing_chat = false,
            dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
            enable_logging = false,
          },
        },
      },
      opts = {
        log_level = "DEBUG",
      },
      prompt_library = {
        ["NeoVim Expert"] = {
          strategy = "chat",
          description = "Chatting with a Neovim Expert",
          opts = {
            index = 2,
            short_name = "nvim",
          },
          references = {
            type = "url",
            url = "https://raw.githubusercontent.com/nvim-neorocks/nvim-best-practices/refs/heads/main/README.md",
          },
          prompts = {
            {
              role = "system",
              content = "You are Folke Lemaitre, creator of LazyVim and countless NeoVim plugins. You are an expert developer with Lua and Neovim. You have deep knowledge of NeoVim and Lua. You know everything there is to know about creating NeoVim plugins, including but not limited to: Best practices, how to structure plugins, how to test them, and how to document them. You implement the users requests and provide guidance. When creating code consider best practices for Lua and NeoVim development. You include relevant references to existing documentation when using NeoVim APIs.\n\n",
              opts = {
                visible = false,
              },
            },
            {
              role = "user",
              content = "\n\n",
            },
          },
        },
        ["Writer"] = {
          strategy = "chat",
          description = "Chatting with a Technical Writer",
          opts = {
            index = 2,
            short_name = "nvim",
          },
          prompts = {
            {
              role = "system",
              content = "You are an expert technical writer, who is also an expert programmer. It is your job to write engaging yet original an humorous technical articles on a variety of topics. You avoid mannerisms and AI give-aways such as the excessive use of lists. You are great at imitating the tone and style of existing pieces of writing.\n\n",
              opts = {
                visible = false,
              },
            },
            {
              role = "user",
              content = "\n\n",
            },
          },
        },
      },
    },
    keys = {
      { "<C-c>", "", desc = "+codecompanion" },
      { "<C-c><C-i>", "<cmd>CodeCompanion", desc = "Code Companion Inline", mode = { "n", "v" } },
      { "<C-c><C-c>", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Code Companion Chat Toggle", mode = { "n", "v" } },
      { "<C-c><C-a>", "<cmd>CodeCompanionChat Add<cr>", desc = "Code Companion Chat Add", mode = { "v" } },
      { "<C-c><C-a>", "<cmd>CodeCompanionActions<cr>", desc = "Code Companion Actions", mode = { "n" } },
      { "<C-c><C-h>", "<cmd>CodeCompanionHistory<cr>", desc = "Code Companion History", mode = { "n" } },
    },
  },
}
