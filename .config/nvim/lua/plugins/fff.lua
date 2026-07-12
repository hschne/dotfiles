return {
  "dmtrKovalenko/fff.nvim",
  dependencies = { "folke/snacks.nvim" },
  build = function()
    require("fff.download").download_or_build_binary()
  end,
  lazy = false,
  opts = {
    prompt = "> ",
  },
  config = function(_, opts)
    require("fff").setup(opts)
    require("fff_picker").setup({ prompt = opts.prompt })
  end,
  keys = {
    {
      "<leader><space>",
      function()
        require("fff_picker").find_files({ cwd = LazyVim.root() })
      end,
      desc = "Find Files (Root Dir)",
    },
    {
      "<leader>ff",
      function()
        require("fff_picker").find_files({ cwd = LazyVim.root() })
      end,
      desc = "Find Files (Root Dir)",
    },
    {
      "<leader>fF",
      function()
        require("fff_picker").find_files({ cwd = vim.uv.cwd() })
      end,
      desc = "Find Files (cwd)",
    },
    {
      "<leader>/",
      function()
        require("fff_picker").live_grep({ cwd = LazyVim.root() })
      end,
      desc = "Grep (Root Dir)",
    },
    {
      "<leader>sg",
      function()
        require("fff_picker").live_grep({ cwd = LazyVim.root() })
      end,
      desc = "Grep (Root Dir)",
    },
    {
      "<leader>sG",
      function()
        require("fff_picker").live_grep({ cwd = vim.uv.cwd() })
      end,
      desc = "Grep (cwd)",
    },
    {
      "<leader>sw",
      function()
        require("fff_picker").grep_word({ cwd = LazyVim.root() })
      end,
      mode = { "n", "x" },
      desc = "Visual selection or word (Root Dir)",
    },
    {
      "<leader>sW",
      function()
        require("fff_picker").grep_word({ cwd = vim.uv.cwd() })
      end,
      mode = { "n", "x" },
      desc = "Visual selection or word (cwd)",
    },
  },
}
