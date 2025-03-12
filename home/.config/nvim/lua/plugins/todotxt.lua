return {
  {
    "hschne/todo.nvim",
    lazy = false,
    dir = "~/Source/todox.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
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
        "<leader>od",
        function()
          require("todox").open_done()
        end,
        desc = "Open Done",
      },
      {
        "<leader>os",
        "",
        desc = "+sort",
      },
      {
        "<leader>osa",
        function()
          require("todox").sort_by("name")
        end,
        desc = "+sort",
      },
      {
        "<leader>osp",
        function()
          require("todox").sort_by("priority")
        end,
        desc = "Sort by Priority",
      },
      {
        "<leader>oso",
        function()
          require("todox").sort_by("project")
        end,
        desc = "Sort by Project",
      },
      {
        "<leader>osc",
        function()
          require("todox").sort_by("context")
        end,
        desc = "Sort by Context",
      },
      {
        "<leader>osd",
        function()
          require("todox").sort_by("due")
        end,
        desc = "Sort by Due Date",
      },
      {
        "<leader>ox",
        function()
          require("todox").toggle_todo_state()
        end,
        desc = "Toggle Task State",
      },
      {
        "<leader>oc",
        function()
          require("todox").move_done_tasks()
        end,
        desc = "Archive Done Tasks",
      },
      {
        "<leader>oa",
        function()
          require("todox").add_priority()
        end,
        desc = "Add Priority",
      },
      {
        "<leader>op",
        function()
          require("todox").add_project_tag()
        end,
        mode = { "n", "v" },
        desc = "Add Project Tag",
      },
      {
        "<C-c><C-n>",
        function()
          require("todox").capture_todo()
        end,
        desc = "Create New Todo",
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
