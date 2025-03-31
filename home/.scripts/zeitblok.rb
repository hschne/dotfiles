#!/usr/bin/env ruby
require 'thor'
require 'date'
require 'csv'
require 'fileutils'

class TimeTracker < Thor
  def self.exit_on_failure?
    false
  end

  desc 'log TIME *TAGS', 'Log time entry with duration (format: minutes or HH:MM) and tags'
  def log(time_input, *tags)
    minutes = parse_time(time_input)
    current_date = Date.today.strftime('%Y/%m/%d')
    file_path = get_file_path
    FileUtils.mkdir_p(File.dirname(file_path))

    formatted_minutes = format_minutes(minutes)
    entry = [current_date, formatted_minutes, tags.join(', ')]

    File.open(file_path, 'a') do |file|
      file.puts(CSV.generate_line(entry))
    end

    puts "Successfully logged #{formatted_minutes} with tags: #{tags.join(', ')}"
  rescue ArgumentError => e
    puts "Error: #{e.message}"
  end

  desc 'summary *TAGS', 'Summarize time spent on specified tags, optionally within a date range'
  method_option :from, type: :string, desc: 'Start date (format: YYYY-MM-DD)'
  method_option :to, type: :string, desc: 'End date (format: YYYY-MM-DD)'
  method_option :range, type: :string, enum: %w[day week month year], desc: 'Predefined date range'
  def summary(*tags)
    file_path = get_file_path

    unless File.exist?(file_path)
      puts 'No time entries found.'
      return
    end

    if options[:range]
      start_date, end_date = calculate_date_range(options[:range])
    else
      start_date = options[:from] ? Date.parse(options[:from]) : Date.new(1900)
      end_date = options[:to] ? Date.parse(options[:to]) : Date.today
    end

    total_minutes = 0
    matching_entries = []

    CSV.foreach(file_path) do |row|
      date = Date.parse(row[0])
      next unless date >= start_date && date <= end_date

      entry_tags = row[2].split(', ')
      if tags.empty? || tags.all? { |tag| entry_tags.include?(tag) }
        # Convert HH:MM to minutes for calculations
        hours, minutes = row[1].split(':').map(&:to_i)
        total_minutes += (hours * 60) + minutes

        matching_entries << {
          date: date.strftime('%Y/%m/%d'),
          time: row[1],
          tags: row[2]
        }
      end
    end

    if matching_entries.empty?
      puts 'No entries found matching the specified criteria.'
      return
    end

    # Print summary
    puts "\nTime Summary:"
    puts '-------------'
    puts "Total Time: #{format_minutes(total_minutes)}"
    puts "Tags: #{tags.empty? ? 'All' : tags.join(', ')}"
    puts "Date: #{start_date.strftime('%Y/%m/%d')} to #{end_date.strftime('%Y/%m/%d')}"

    puts "\nMatching Entries:"
    puts '----------------'
    matching_entries.each do |entry|
      puts "#{entry[:date]} - #{entry[:time]} - #{entry[:tags]}"
    end
  rescue Date::Error
    puts 'Error: Dates must be in YYYY-MM-DD format'
  rescue StandardError => e
    puts "Error occurred: #{e.message}"
  end

  desc 'edit', 'Open the time tracking file in your default editor'
  def edit
    file_path = get_file_path
    unless File.exist?(file_path)
      puts "Time tracking file doesn't exist yet. Create some entries first."
      return
    end

    editor = ENV['EDITOR'] || ENV['VISUAL']
    if editor.nil?
      if RUBY_PLATFORM.match?(/mswin|mingw|cygwin/)
        system('notepad', file_path)
      else
        system('open', file_path) if RUBY_PLATFORM.match?(/darwin/)
        system('xdg-open', file_path) if RUBY_PLATFORM.match?(/linux/)
      end
    else
      system("#{editor} #{file_path}")
    end
  end

  desc 'tags', 'List all unique tags used in time entries'
  def tags
    all_tags = get_tags
    if all_tags.empty?
      puts 'There are no tags yet!'
      return
    end

    all_tags.sort.join("\n")
  end

  desc 'completion', 'Generate shell completion script'
  method_option :shell, aliases: '-s', type: :string, required: true, enum: %w[bash zsh], desc: 'Shell type'
  def completion
    shell = options[:shell]

    case shell
    when 'zsh'
      puts %{
# ZSH Completion for TimeTracker
_zeitblok() {
  local -a commands options

  _arguments -C \
    '1: :->command' \
    '*: :->args'

  case $state in
    command)
      local -a cmds
      cmds=($(zeitblok complete commands))
      _describe -t commands 'zeitblok commands' cmds
      ;;
    args)
      case $line[1] in
        summary)
          local -a opts
          opts=($(zeitblok complete options summary))
          _arguments -s $opts

          # Complete tags
          local -a tags
          tags=($(zeitblok complete tags))
          _values 'tags' $tags
          ;;
        log)
          # For the first argument (time), we don't provide completion
          if (( CURRENT > 2 )); then
            # Complete tags for subsequent arguments
            local -a tags
            tags=($(zeitblok complete tags))
            _values 'tags' $tags
          fi
          ;;
      esac
      ;;
  esac
}

compdef _zeitblok zeitblok
}
    when 'bash'
      puts %{
# Bash completion for TimeTracker
_zeitblok() {
  local cur prev words cword
  _init_completion || return

  if [ $cword -eq 1 ]; then
    # Complete commands
    COMPREPLY=($(compgen -W "$(zeitblok complete commands | cut -d':' -f1)" -- "$cur"))
    return 0
  fi

  case ${words[1]} in
    summary)
      if [[ "$cur" == -* ]]; then
        # Complete options
        COMPREPLY=($(compgen -W "$(zeitblok complete options summary | cut -d'=' -f1)" -- "$cur"))
      else
        # Complete tags
        COMPREPLY=($(compgen -W "$(zeitblok complete tags)" -- "$cur"))
      fi
      ;;
    log)
      if [ $cword -gt 2 ]; then
        # Complete tags after the time argument
        COMPREPLY=($(compgen -W "$(zeitblok complete tags)" -- "$cur"))
      fi
      ;;
  esac
}

complete -F _zeitblok zeitblok
}
    end
  end

  desc 'complete TYPE [COMMAND]', 'Return completion information of specified type'
  def complete(type, command = nil)
    case type
    when 'commands'
      commands = {
        'log' => 'Log time entry with duration (format: minutes or HH:MM) and tags',
        'summary' => 'Summarize time spent on specified tags, optionally within a date range',
        'edit' => 'Open the time tracking file in your default editor',
        'tags' => 'List all unique tags used in time entries',
        'completion' => 'Generate shell completion script',
        'complete' => 'Return completion information of specified type'
      }
      commands.each { |cmd, desc| puts "#{cmd}:#{desc}" }

    when 'options'
      case command
      when 'summary'
        puts '--from=[Start date (format: YYYY-MM-DD)]'
        puts '--to=[End date (format: YYYY-MM-DD)]'
        puts '--range=[Predefined date range]:(day week month year)'
      end

    when 'tags'
      all_tags = get_tags
      tags.sort.join("\n") unless all_tags.empty?
    end
  end

  private

  def get_tags
    file_path = get_file_path

    return [] unless File.exist?(file_path)

    all_tags = Set.new
    CSV.foreach(file_path) do |row|
      entry_tags = row[2].split(', ')
      all_tags.merge(entry_tags)
    end
    puts all_tags

    all_tags
  end

  def calculate_date_range(range_type)
    today = Date.today
    case range_type
    when 'day'
      [today, today]
    when 'week'
      start_date = today - today.wday  # Start of week (Sunday)
      [start_date, start_date + 6]     # Sunday to Saturday
    when 'month'
      start_date = Date.new(today.year, today.month, 1)
      end_date = Date.new(today.year, today.month, -1) # Last day of month
      [start_date, end_date]
    when 'year'
      start_date = Date.new(today.year, 1, 1)
      end_date = Date.new(today.year, 12, 31)
      [start_date, end_date]
    end
  end

  def get_file_path
    File.join(Dir.home, 'Documents', 'time.txt')
  end

  def parse_time(time_input)
    total_minutes = if time_input.include?(':')
                      hours, minutes = time_input.split(':').map(&:to_i)
                      (hours * 60) + minutes
                    else
                      hours = Integer(time_input)
                      hours * 60
                    end

    (total_minutes / 15.0).round * 15
  rescue ArgumentError
    raise ArgumentError, "Time must be in format 'hours' or 'HH:MM'"
  end

  def format_minutes(total_minutes)
    hours = total_minutes / 60
    minutes = total_minutes % 60
    format('%d:%02d', hours, minutes)
  end

  default_task :log
end

TimeTracker.start(ARGV)
