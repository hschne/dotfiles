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
      { "<leader>T", "", desc = "+todo" },
      {
        "<leader>Tt",
        function()
          require("todotxt").open_todo_file()
        end,
        desc = "Open Todo",
      },
      {
        "<leader>Ts",
        function()
          require("todotxt").sort_tasks()
        end,
        desc = "Sort alphabetically",
      },
      {
        "<leader>Tp",
        function()
          require("todotxt").sort_tasks_by_priority()
        end,
        desc = "Sort by priority",
      },
      {
        "<leader>To",
        function()
          require("todotxt").sort_tasks_by_project()
        end,
        desc = "Sort by project",
      },
      {
        "<leader>Td",
        function()
          require("todotxt").sort_tasks_by_due_date()
        end,
        desc = "Sort by due date",
      },
      {
        "<leader>Ta",
        function()
          require("todotxt").move_done_tasks()()
        end,
        desc = "Archive done tasks",
      },
      {
        "<C-c><C-c>",
        function()
          require("todotxt").toggle_todo_state()
        end,
        desc = "Toggle Task",
      },
      {
        "<C-c><C-x>",
        function()
          require("todotxt").cycle_priority()
        end,
        desc = "Toggle Task Priority",
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
