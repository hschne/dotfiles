return {
  {
    "hschne/todo.nvim",
    lazy = false,
    dir = "~/Source/todox.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "arnarg/tree-sitter-todotxt" },
    config = function()
      require("todox").setup({
        todo_files = {
          vim.env.HOME .. "/Documents/Wiki/todo.txt",
          vim.env.HOME .. "/Documents/Wiki/todo-meister.txt",
        },
      })
    end,
    keys = {
      { "<leader>o", "", desc = "+todo" },
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
      {
        "<leader>os",
        function()
          require("todox").sort_by("name")
        end,
        desc = "Sort Alphabetically",
      },
      {
        "<leader>op",
        function()
          require("todox").sort_by("priority")
        end,
        desc = "Sort by Priority",
      },
      {
        "<leader>oP",
        function()
          require("todox").sort_by("project")
        end,
        desc = "Sort by Project",
      },
      {
        "<leader>oc",
        function()
          require("todox").sort_by("context")
        end,
        desc = "Sort by Project",
      },
      {
        "<leader>od",
        function()
          require("todox").sort_by("due")
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
        "<C-c>n",
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
        "<C-c>p",
        function()
          require("todox").add_priority()
        end,
        desc = "Add Priority",
      },
      {
        "<C-c>b",
        function()
          require("todox").add_project_tag()
        end,
        mode = { "n", "v" },
        desc = "Add Project Tag",
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
