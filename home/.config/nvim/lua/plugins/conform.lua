return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        eruby = { "erb_formatter" },
      },
      formatters = {
        erb_formatter = {
          command = "erb-formatter",
          args = { "--stdin" },
        },
      },
    },
  },
}
