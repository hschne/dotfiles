#!/usr/bin/env ruby
require 'thor'
require 'date'
require 'csv'
require 'fileutils'

class TimeTracker < Thor
  def self.exit_on_failure?
    true
  end

  desc 'log TIME *TAGS', 'Log time entry with duration (format: minutes or HH:MM) and tags'
  def log(time_input, *tags)
    minutes = parse_time(time_input)
    current_date = Date.today.strftime('%Y/%m/%d')
    file_path = get_file_path
    FileUtils.mkdir_p(File.dirname(file_path))
    entry = [current_date, minutes, tags.join(', ')]

    File.open(file_path, 'a') do |file|
      file.puts(CSV.generate_line(entry))
    end

    formatted_time = format_minutes(minutes)
    puts "Successfully logged #{formatted_time} with tags: #{tags.join(', ')}"
  rescue ArgumentError => e
    puts "Error: #{e.message}"
  rescue StandardError => e
    puts "Error occurred: #{e.message}"
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

    # Handle predefined ranges
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
        total_minutes = (hours * 60) + minutes

        matching_entries << {
          date: date.strftime('%Y/%m/%d'),
          time: row[1], # Use the original HH:MM format
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
    puts "Date Range: #{start_date.strftime('%Y/%m/%d')} to #{end_date.strftime('%Y/%m/%d')}"
    puts "Range Type: #{options[:range] || 'custom'}"
    puts "Tags: #{tags.empty? ? 'All' : tags.join(', ')}"
    puts "Total Time: #{format_minutes(total_minutes)}"

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
      if RUBY_PLATFORM =~ /mswin|mingw|cygwin/
        system('notepad', file_path)
      else
        system('open', file_path) if RUBY_PLATFORM =~ /darwin/
        system('xdg-open', file_path) if RUBY_PLATFORM =~ /linux/
      end
    else
      system("#{editor} #{file_path}")
    end
  end

  private

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
    if time_input.include?(':')
      hours, minutes = time_input.split(':').map(&:to_i)
      total_minutes = (hours * 60) + minutes
    else
      total_minutes = Integer(time_input) * 60
    end

    (total_minutes / 15.0).round
    hours = rounded_minutes / 60
    minutes = rounded_minutes % 60
    format('%d:%02d', hours, minutes)
  rescue ArgumentError
    raise ArgumentError, "Time must be in format 'HH' or 'HH:MM'"
  end

  def format_minutes(minutes)
    hours = minutes / 60
    remaining_minutes = minutes % 60
    if remaining_minutes == 0
      "#{hours}h"
    else
      "#{hours}h #{remaining_minutes}m"
    end
  end

  default_task :log
end

TimeTracker.start(ARGV)
