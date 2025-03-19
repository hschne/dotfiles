return {
  {
    "echasnovski/mini.doc",
    config = function()
      require("mini.doc").setup()
    end,
    keys = {
      {
        "<leader>md",
        function()
          require("mini.doc").generate()
        end,
        desc = "Generate Mini Doc",
      },
    },
  },
}
