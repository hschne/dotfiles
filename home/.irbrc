# frozen_string_literal: true

require 'irb/completion'

IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = '.irb-history'

require 'reline'

module CustomRelineEditor # Override reverse search (Ctrl+R) behavior
  def reverse_search_history(key, arg: 1)
    raise RuntimeError
    # Remove the exception
    substr = prev_action_state_value(:search_history) == :empty ? '' : current_line.byteslice(0, @byte_pointer)
    return if @history_pointer == 0
    return if @history_pointer.nil? && substr.empty? && !current_line.empty?

    history_range = 0...(@history_pointer || Reline::HISTORY.size)
    h_pointer, line_index = search_history(substr, history_range.reverse_each)
    return unless h_pointer

    move_history(h_pointer, line: line_index || :start, cursor: substr.empty? ? :end : @byte_pointer)
    arg -= 1
    set_next_action_state(:search_history, :empty) if substr.empty?
    ed_search_prev_history(key, arg: arg) if arg > 0
  end

  # You can customize other methods here as well
end

Reline::LineEditor.prepend(CustomRelineEditor)
