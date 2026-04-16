# frozen_string_literal: true

require 'irb/completion'

IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = '.irb-history'
IRB.conf[:AUTO_INDENT] = true

def safe_require(dependency)
  require dependency
  yield
rescue LoadError
  # Failed to load dependency
end

safe_require('amazing_print') { AmazingPrint.irb! }
