return {
  {
    "telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
        require("telescope").load_extension("fzf")
        require("telescope").load_extension("file_browser")
      end,
    },
    setup = {
      extensions = {
        file_browser = {
          theme = "ivy",
          hijack_netrw = true,
        },
      },
    },
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>fo", "<cmd>Telescope file_browser<cr>", desc = "Telescope File Browser" },
      {
        "<leader>fO",
        "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>",
        desc = "Telescope File Browser in Current Directory",
      },
    },
  },
}
