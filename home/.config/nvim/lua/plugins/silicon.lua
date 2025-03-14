return {
  {
    "narutoxy/silicon.lua",
    requires = { "nvim-lua/plenary.nvim" },
    opts = {
      output = vim.env.HOME .. "/Downloads/Code_${year}${month}${date}${time}.png",
      windowControls = false,
      bgColor = "#9aa5ce",
    },
    keys = {
      {
        "<leader>S",
        "",
        mode = { "n", "v" },
        desc = "+silicon",
      },
      {
        "<leader>Sy",
        function()
          require("silicon").visualise_api({ to_clip = true })
        end,
        mode = { "v" },
        desc = "Copy Image of Selection",
      },
      {
        "<leader>Ss",
        function()
          require("silicon").visualise_api({})
        end,
        mode = { "v" },
        desc = "Create Image of Selection",
      },
      {
        "<leader>Sy",
        function()
          require("silicon").visualise_api({ to_clip = true, show_buf = true })
        end,
        mode = { "n" },
        desc = "Copy Image of Buffer",
      },
      {
        "<leader>Ss",
        function()
          require("silicon").visualise_api({ show_buf = true })
        end,
        mode = { "n" },
        desc = "Create Image of Buffer",
      },
    },
  },
}
