# frozen_string_literal: true

require "irb/completion"

IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = "#{Dir.home}/.irb-history"
IRB.conf[:PROMPT_MODE] = :SIMPLE

ENV["RACK_ENV"] ||= "development"
