return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  keys = {
    -- Main actions
    {
      "<C-c>a",
      function()
        require("opencode").ask("@this: ", { submit = true })
      end,
      mode = { "n", "x" },
      desc = "Ask opencode",
    },
    {
      "<C-c>s",
      function()
        require("opencode").select()
      end,
      mode = { "n", "x" },
      desc = "Select opencode action",
    },
    {
      "<C-c><C-c>",
      function()
        require("opencode").toggle()
      end,
      mode = { "n", "t" },
      desc = "Switch to opencode window or toggle",
    },

    -- Operators
    {
      "<C-c>o",
      function()
        return require("opencode").operator("@this ")
      end,
      mode = { "n", "x" },
      expr = true,
      desc = "Add range to opencode",
    },
    {
      "<C-c>l",
      function()
        return require("opencode").operator("@this ") .. "_"
      end,
      mode = "n",
      expr = true,
      desc = "Add line to opencode",
    },

    -- Navigation
    {
      "<C-c>u",
      function()
        require("opencode").command("session.half.page.up")
      end,
      mode = "n",
      desc = "OpenCode half page up",
    },
    {
      "<C-c>d",
      function()
        require("opencode").command("session.half.page.down")
      end,
      mode = "n",
      desc = "OpenCode half page down",
    },

    -- Preserve original increment/decrement
    { "+", "<C-a>", mode = "n", desc = "Increment", noremap = true },
    { "-", "<C-x>", mode = "n", desc = "Decrement", noremap = true },
  },
  config = function()
    -- Required for `opts.events.reload`.
    vim.o.autoread = true

    vim.g.opencode_opts = {
      provider = {
        toggle = function(self)
          -- Get current session
          local current_session = vim.fn.system("tmux display-message -p '#{session_name}'"):gsub("\n", "")
          
          -- Find existing opencode pane in current session
          local panes = vim.fn.system("tmux list-panes -a -F '#{pane_id} #{pane_current_command} #{session_name}'")
          local existing_pane = nil
          
          for line in panes:gmatch("[^\r\n]+") do
            local pane_id, command, session = line:match("([^%s]+) ([^%s]+) ([^%s]+)")
            if command == "opencode" and session == current_session then
              existing_pane = pane_id
              break
            end
          end
          
          if existing_pane then
            -- Switch to existing pane and focus it
            vim.fn.system("tmux select-pane -t " .. existing_pane)
            vim.fn.system("tmux select-window -t " .. existing_pane)
            print("Switched to existing opencode pane: " .. existing_pane)
          else
            -- Create new pane
            local new_pane = vim.fn.system("tmux split-window -d -P -F '#{pane_id}' -v 'opencode'"):gsub("\n", "")
            vim.fn.system("tmux select-pane -t " .. new_pane)
            print("Created new opencode pane: " .. new_pane)
          end
        end,
      },
    }
  end,
}
