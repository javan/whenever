require 'fileutils'

module Whenever
  class CommandLine
    def self.execute(options={})
      new(options).run
    end

    def initialize(options={})
      @options = options

      @options[:crontab_command] ||= 'crontab'
      @options[:file]            ||= 'config/schedule.rb'
      @options[:cut]             ||= 0

      if !File.exist?(@options[:file]) && @options[:clear].nil?
        warn("[fail] Can't find file: #{@options[:file]}")
        exit(1)
      end

      if [@options[:update], @options[:write], @options[:clear]].compact.length > 1
        warn("[fail] Can only update, write or clear. Choose one.")
        exit(1)
      end

      unless @options[:cut].to_s =~ /[0-9]*/
        warn("[fail] Can't cut negative lines from the crontab #{options[:cut]}")
        exit(1)
      end
      @options[:cut] = @options[:cut].to_i

      @timestamp = Time.now.to_s
    end

    def run
      if @options[:update] || @options[:clear]
        write_crontab(updated_crontab)
      elsif @options[:write]
        write_crontab(whenever_cron)
      else
        puts Whenever.cron(@options)
        puts "## [message] Above is your schedule file converted to cron syntax; your crontab file was not updated."
        puts "## [message] Run `whenever --help' for more options."
        exit(0)
      end
    end

  protected

    def default_identifier
      File.expand_path(@options[:file])
    end

    def identifier
      @options[:identifier] ||
        whenever_job_list.respond_to?(:identifier) && whenever_job_list.identifier ||
        default_identifier
    end

    def whenever_cron
      return '' if @options[:clear]
      @whenever_cron ||= [
        comment_open, whenever_job_list.generate_cron_output, comment_close
      ].compact.join("\n") + "\n"
    end

    def whenever_job_list
      @whenever_job_list ||= Whenever.job_list(@options)
    end

    def read_crontab
      return @current_crontab if instance_variable_defined?(:@current_crontab)

      command = [@options[:crontab_command]]
      command << '-l'
      command << "-u #{@options[:user]}" if @options[:user]

      command_results  = %x[#{command.join(' ')} 2> /dev/null]
      @current_crontab = $?.exitstatus.zero? ? prepare(command_results) : ''
    end

    def write_crontab(contents)
      command = [@options[:crontab_command]]
      command << "-u #{@options[:user]}" if @options[:user]
      # Solaris/SmartOS cron does not support the - option to read from stdin.
      command << "-" unless OS.solaris?

      IO.popen(command.join(' '), 'r+') do |crontab|
        crontab.write(contents)
        crontab.close_write
      end

      success = $?.exitstatus.zero?

      if success
        action = 'written' if @options[:write]
        action = 'updated' if @options[:update]
        puts "[write] crontab file #{action}"
        exit(0)
      else
        warn "[fail] Couldn't write crontab; try running `whenever' with no options to ensure your schedule file is valid."
        exit(1)
      end
    end

    def updated_crontab
      # Check for unopened or unclosed identifier blocks
      if read_crontab =~ Regexp.new("^#{comment_open_regex}\s*$") && (read_crontab =~ Regexp.new("^#{comment_close_regex}\s*$")).nil?
        warn "[fail] Unclosed indentifier; Your crontab file contains '#{comment_open(false)}', but no '#{comment_close(false)}'"
        exit(1)
      elsif (read_crontab =~ Regexp.new("^#{comment_open_regex}\s*$")).nil? && read_crontab =~ Regexp.new("^#{comment_close_regex}\s*$")
        warn "[fail] Unopened indentifier; Your crontab file contains '#{comment_close(false)}', but no '#{comment_open(false)}'"
        exit(1)
      end

      # If an existing identifier block is found, replace it with the new cron entries
      if read_crontab =~ Regexp.new("^#{comment_open_regex}\s*$") && read_crontab =~ Regexp.new("^#{comment_close_regex}\s*$")
        # If the existing crontab file contains backslashes they get lost going through gsub.
        # .gsub('\\', '\\\\\\') preserves them. Go figure.
        read_crontab.gsub(Regexp.new("^#{comment_open_regex}\s*$.+^#{comment_close_regex}\s*$", Regexp::MULTILINE), whenever_cron.chomp.gsub('\\', '\\\\\\'))
      else # Otherwise, append the new cron entries after any existing ones
        [read_crontab, whenever_cron].join("\n\n")
      end.gsub(/\n{3,}/, "\n\n") # More than two newlines becomes just two.
    end

    def prepare(contents)
      # Strip n lines from the top of the file as specified by the :cut option.
      # Use split with a -1 limit option to ensure the join is able to rebuild
      # the file with all of the original seperators in-tact.
      stripped_contents = contents.split($/,-1)[@options[:cut]..-1].join($/)

      # Some cron implementations require all non-comment lines to be newline-
      # terminated. (issue #95) Strip all newlines and replace with the default
      # platform record seperator ($/)
      stripped_contents.gsub!(/\s+$/, $/)
    end

    def comment_base(include_timestamp = true)
      if include_timestamp
        "Whenever generated tasks for: #{identifier} at: #{@timestamp}"
      else
        "Whenever generated tasks for: #{identifier}"
      end
    end

    def comment_open(include_timestamp = true)
      "# Begin #{comment_base(include_timestamp)}"
    end

    def comment_close(include_timestamp = true)
      "# End #{comment_base(include_timestamp)}"
    end

    def comment_open_regex
      "#{comment_open(false)}(#{timestamp_regex}|)"
    end

    def comment_close_regex
      "#{comment_close(false)}(#{timestamp_regex}|)"
    end

    def timestamp_regex
      " at: \\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2} ([+-]\\d{4}|UTC)"
    end
  end
end
