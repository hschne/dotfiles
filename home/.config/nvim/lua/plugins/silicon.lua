return {
  {
    "narutoxy/silicon.lua",
    requires = { "nvim-lua/plenary.nvim" },
    dir = "~/Source/forks/silicon.lua",
    opts = {
      output = vim.env.HOME .. "/Pictures/Screenshots/Code_${year}${month}${date}${time}.png",
      windowControls = false,
      lineNumber = false,
      gobble = true,
      bgColor = "#9aa5ce",
      font = "SauceCodePro Nerd Font",
    },
    keys = {
      {
        "<leader>p",
        "",
        mode = { "n", "v" },
        desc = "+utilities",
      },
      {
        "<leader>py",

        function()
          require("silicon").visualise_api({ to_clip = true })
        end,
        mode = { "v" },
        desc = "Copy Image of Selection",
      },
      {
        "<leader>ps",
        function()
          require("silicon").visualise_api()
        end,
        mode = { "v" },
        desc = "Create Image of Selection",
      },
      {
        "<leader>py",
        function()
          require("silicon").visualise_api({ to_clip = true, show_buf = true })
        end,
        mode = { "n" },
        desc = "Copy Image of Buffer",
      },
      {
        "<leader>ps",
        function()
          require("silicon").visualise_api({ show_buf = true })
        end,
        mode = { "n" },
        desc = "Create Image of Buffer",
      },
    },
  },
}
