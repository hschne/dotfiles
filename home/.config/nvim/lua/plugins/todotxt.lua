return {
  {
    "phrmendes/todotxt.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "arnarg/tree-sitter-todotxt" },
    config = function()
      require("todotxt").setup({
        todotxt = os.getenv("HOME") .. "/Documents/Wiki/todo.txt",
        donetxt = os.getenv("HOME") .. "/Documents/Wiki/todo.done.txt",
      })
    end,
    ft = "todotxt",
    keys = {
      { "<leader>o", "", desc = "+todo" },
      {
        "<leader>ot",
        function()
          require("todotxt").open_todo_file()
        end,
        desc = "Open Todo",
      },
      {
        "<leader>os",
        function()
          require("todotxt").sort_tasks()
        end,
        desc = "Sort Alphabetically",
      },
      {
        "<leader>op",
        function()
          require("todotxt").sort_tasks_by_priority()
        end,
        desc = "Sort by Priority",
      },
      {
        "<leader>oP",
        function()
          require("todotxt").sort_tasks_by_project()
        end,
        desc = "Sort by Project",
      },
      {
        "<leader>od",
        function()
          require("todotxt").sort_tasks_by_due_date()
        end,
        desc = "Sort by Due Date",
      },
      {
        "<leader>oa",
        function()
          require("todotxt").move_done_tasks()
        end,
        desc = "Archive Done Tasks",
      },
      {
        "<C-c><C-v>",
        function()
          require("todotxt").capture_todo()
        end,
        desc = "Create New Todo",
      },
      {
        "<C-c><C-c>",
        function()
          require("todotxt").toggle_todo_state()
        end,
        desc = "Toggle Task State",
      },
      {
        "<C-c><C-x>",
        function()
          require("todotxt").cycle_priority()
        end,
        desc = "Toggle task Priority",
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
