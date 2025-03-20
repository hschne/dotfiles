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
        "<leader>fo",
        function()
          require("todox").open_todo()
        end,
        desc = "Open Todo",
      },
      {
        "<leader>fd",
        function()
          require("todox").open_done()
        end,
        desc = "Open Done",
      },
      { "<leader>T", "", desc = "+todo" },
      {
        "<leader>Ts",
        "",
        desc = "+sort",
      },
      {
        "<leader>Tsn",
        function()
          require("todox").sort_by("name")
        end,
        desc = "+sort",
      },
      {
        "<leader>Tsp",
        function()
          require("todox").sort_by("priority")
        end,
        desc = "Sort by Priority",
      },
      {
        "<leader>TsP",
        function()
          require("todox").sort_by("project")
        end,
        desc = "Sort by Project",
      },
      {
        "<leader>Tsc",
        function()
          require("todox").sort_by("context")
        end,
        desc = "Sort by Context",
      },
      {
        "<leader>Tsd",
        function()
          require("todox").sort_by("due")
        end,
        desc = "Sort by Due Date",
      },
      {
        "<leader>Ta",
        function()
          require("todox").archive_done_tasks()
        end,
        desc = "Archive Done Tasks",
      },
      {
        "<leader>Tp",
        function()
          require("todox").add_priority()
        end,
        mode = { "n", "v" },
        desc = "Add Priority",
        noremap = true,
      },
      {
        "<leader>TP",
        function()
          require("todox").add_project_tag()
        end,
        mode = { "n", "v" },
        desc = "Add Project Tag",
      },
      {
        "<leader>Tn",
        function()
          require("todox").capture_todo()
        end,
        desc = "Create New Task",
      },
      {
        "<leader>Tx",
        function()
          require("todox").toggle_todo_state()
        end,
        desc = "Toggle Task State",
      },

      {
        "<C-x><C-n>",
        function()
          require("todox").capture_todo()
        end,
        desc = "Create New Todo",
      },
      {
        "<C-x><C-x>",
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
