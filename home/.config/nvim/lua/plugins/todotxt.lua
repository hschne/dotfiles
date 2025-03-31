return {
  {
    "hschne/todo.nvim",
    lazy = false,
    dir = "~/Source/todox.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "ibhagwan/fzf-lua" },
    config = function()
      require("todox").setup({
        todo_files = {
          "./todo.txt",
          "~/Documents/Wiki/todo.txt",
          "~/Documents/Wiki/todo-meister.txt",
        },
      })
    end,
    keys = {
      {
        "<leader>ot",
        function()
          require("todox").open_todo()
        end,
        desc = "Open Todo",
      },
      {
        "<leader>oT",
        function()
          require("todox").open_done()
        end,
        desc = "Open Done",
      },
      { "<C-x>", "", desc = "+todo" },
      {
        "<C-x>t",
        function()
          require("todox").open_todo()
        end,
        desc = "Open Todo",
      },
      {
        "<C-x>T",
        function()
          require("todox").open_done()
        end,
        desc = "Open Done",
      },
      {
        "<C-x>s",
        function()
          require("todox").sort_by("priority")
        end,
        desc = "Sort by Priority",
      },
      {
        "<C-x>a",
        function()
          require("todox").archive_done_tasks()
        end,
        desc = "Archive Done Tasks",
      },
      {
        "<C-x>p",
        function()
          require("todox").add_priority()
        end,
        mode = { "n", "v" },
        desc = "Add Priority",
        noremap = true,
      },
      {
        "<C-x>P",
        function()
          require("todox").add_project_tag()
        end,
        mode = { "n", "v" },
        desc = "Add Project Tag",
      },
      {
        "<C-x>n",
        function()
          require("todox").capture_todo()
        end,
        desc = "Create New Todo",
      },
      {
        "<C-x>x",
        function()
          require("todox").toggle_todo_state()
        end,
        desc = "Toggle Task State",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "todotxt",
      },
    },
  },
}
