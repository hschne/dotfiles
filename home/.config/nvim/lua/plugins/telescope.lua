return {
  {
    "telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      config = function()
        require("telescope").load_extension("fzf")
      end,
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
    config = function()
      require("telescope").setup({
        extensions = {
          file_browser = {
            grouped = true,
            hijack_netrw = true,
            hidden = { file_browser = true, folder_browser = true },
            depth = 1,
          },
        }
      })
      require("telescope").load_extension("file_browser")
    end
  },
}
