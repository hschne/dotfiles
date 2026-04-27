th.git = th.git or {}
th.git.modified_sign = "M "
th.git.added_sign = "+ "
th.git.untracked_sign = "? "
th.git.ignored_sign = "I "
th.git.deleted_sign = "D "
th.git.updated_sign = "U "
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
