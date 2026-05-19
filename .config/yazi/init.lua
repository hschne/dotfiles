-- Tokyo Night-ish Git status icons for git.yazi.
-- Requires a Nerd Font; JetBrains/SauceCode Nerd Fonts are installed locally.
th.git = th.git or {}

th.git.modified = ui.Style():fg("#e0af68")
th.git.added = ui.Style():fg("#9ece6a")
th.git.untracked = ui.Style():fg("#7dcfff")
th.git.ignored = ui.Style():fg("#565f89")
th.git.deleted = ui.Style():fg("#f7768e")
th.git.updated = ui.Style():fg("#bb9af7")
th.git.clean = ui.Style():fg("#9ece6a")

th.git.modified_sign = "󰏫 "
th.git.added_sign = " "
th.git.untracked_sign = " "
th.git.ignored_sign = " "
th.git.deleted_sign = " "
th.git.updated_sign = " "
th.git.clean_sign = ""

require("git"):setup {
  order = 1500,
}

require("zoxide"):setup {
  update_db = true,
}

require("full-border"):setup {
  type = ui.Border.ROUNDED,
}
