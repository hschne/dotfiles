return {
  {
    "hschne/todo.nvim",
    dir = "~/Source/todox.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "arnarg/tree-sitter-todotxt" },
    config = function()
      require("todox").setup({
        todo_files = { vim.env.HOME .. "/Documents/Wiki/todo.txt" },
      })
    end,
    ft = "todotxt",
    keys = {
      { "<leader>o", "", desc = "+todo" },
      {
        "<leader>ot",
        function()
          require("todox").open_todo_file()
        end,
        desc = "Open Todo",
      },
      {
        "<leader>os",
        function()
          require("todox").sort_tasks()
        end,
        desc = "Sort Alphabetically",
      },
      {
        "<leader>op",
        function()
          require("todox").sort_tasks_by_priority()
        end,
        desc = "Sort by Priority",
      },
      {
        "<leader>oP",
        function()
          require("todox").sort_tasks_by_project()
        end,
        desc = "Sort by Project",
      },
      {
        "<leader>od",
        function()
          require("todox").sort_tasks_by_due_date()
        end,
        desc = "Sort by Due Date",
      },
      {
        "<leader>oa",
        function()
          require("todox").move_done_tasks()
        end,
        desc = "Archive Done Tasks",
      },
      {
        "<C-c><C-v>",
        function()
          require("todox").capture_todo()
        end,
        desc = "Create New Todo",
      },
      {
        "<C-c><C-c>",
        function()
          require("todox").toggle_todo_state()
        end,
        desc = "Toggle Task State",
      },
      {
        "<C-c><C-x>",
        function()
          require("todox").cycle_priority()
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
