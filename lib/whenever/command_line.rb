require 'fileutils'
require 'tempfile'

module Whenever
  class CommandLine
    
    def self.execute(options={})
      new(options).run
    end
    
    def initialize(options={})
      @options = options
      
      @options[:file]       ||= 'config/schedule.rb'
      @options[:cut]        ||= 0
      @options[:identifier] ||= default_identifier
      
      unless File.exists?(@options[:file])
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
      
    end
    
    def run
      if @options[:update] || @options[:clear]
        write_crontab(updated_crontab)
      elsif @options[:write]
        write_crontab(whenever_cron)
      else
        puts Whenever.cron(@options)
        exit(0)
      end
    end
    
  protected
    
    def default_identifier
      File.expand_path(@options[:file])
    end
  
    def whenever_cron
      @whenever_cron ||= [comment_open, (Whenever.cron(@options) unless @options[:clear]), comment_close].compact.join("\n") + "\n"
    end
    
    def read_crontab
      return @current_crontab if @current_crontab
      
      command = ['crontab -l']
      command << "-u #{@options[:user]}" if @options[:user]
      
      command_results  = %x[#{command.join(' ')} 2> /dev/null]
      @current_crontab = $?.exitstatus.zero? ? prepare(command_results) : ''
    end
    
    def write_crontab(contents)
      tmp_cron_file = Tempfile.new('whenever_tmp_cron').path
      File.open(tmp_cron_file, File::WRONLY | File::APPEND) do |file|
        file << contents
      end

      command = ['crontab']
      command << "-u #{@options[:user]}" if @options[:user]
      command << tmp_cron_file

      if system(command.join(' '))
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
      if read_crontab =~ Regexp.new("^#{comment_open}$") && (read_crontab =~ Regexp.new("^#{comment_close}$")).nil?
        warn "[fail] Unclosed indentifier; Your crontab file contains '#{comment_open}', but no '#{comment_close}'"
        exit(1)
      elsif (read_crontab =~ Regexp.new("^#{comment_open}$")).nil? && read_crontab =~ Regexp.new("^#{comment_close}$")
        warn "[fail] Unopened indentifier; Your crontab file contains '#{comment_close}', but no '#{comment_open}'"
        exit(1)
      end
      
      # If an existing identier block is found, replace it with the new cron entries
      if read_crontab =~ Regexp.new("^#{comment_open}$") && read_crontab =~ Regexp.new("^#{comment_close}$")
        # If the existing crontab file contains backslashes they get lost going through gsub.
        # .gsub('\\', '\\\\\\') preserves them. Go figure.
        read_crontab.gsub(Regexp.new("^#{comment_open}$.+^#{comment_close}$", Regexp::MULTILINE), whenever_cron.chomp.gsub('\\', '\\\\\\'))
      else # Otherwise, append the new cron entries after any existing ones
        [read_crontab, whenever_cron].join("\n\n")
      end
    end
    
    def prepare(contents)
      contents.split("\n")[@options[:cut]..-1].join("\n")
    end
    
    def comment_base
      "Whenever generated tasks for: #{@options[:identifier]}"
    end
    
    def comment_open
      "# Begin #{comment_base}"
    end
    
    def comment_close
      "# End #{comment_base}"
    end
    
  end
end
