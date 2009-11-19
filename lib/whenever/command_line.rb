module Whenever
  class CommandLine
    
    def self.execute(options={})
      new(options).run
    end
    
    def initialize(options={})
      @options = options
      
      @options[:file]       ||= 'config/schedule.rb'
      @options[:identifier] ||= default_identifier
      
      unless File.exists?(@options[:file])
        warn("[fail] Can't find file: #{@options[:file]}")
        exit(1)
      end

      if @options[:update] && @options[:write]
        warn("[fail] Can't update AND write. choose one.")
        exit(1)
      end
    end
    
    def run
      if @options[:update]
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
      @whenever_cron ||= [comment_open, Whenever.cron(@options), comment_close].join("\n") + "\n"
    end
    
    def read_crontab
      return @current_crontab if @current_crontab
      
      command = ['crontab -l']
      command << "-u #{@options[:user]}" if @options[:user]
      
      command_results  = %x[#{command.join(' ')} 2> /dev/null]
      @current_crontab = $?.exitstatus.zero? ? command_results : ''
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
      if read_crontab.index(comment_open) && !read_crontab.index(comment_close)
        warn "[fail] Unclosed indentifier; Your crontab file contains '#{comment_open}', but no '#{comment_close}'"
        exit(1)
      elsif !read_crontab.index(comment_open) && read_crontab.index(comment_close)
        warn "[fail] Unopened indentifier; Your crontab file contains '#{comment_close}', but no '#{comment_open}'"
        exit(1)
      end
      
      # If an existing identier block is found, replace it with the new cron entries
      if read_crontab.index(comment_open) && read_crontab.index(comment_close)
        read_crontab.gsub(Regexp.new("#{comment_open}.+#{comment_close}", Regexp::MULTILINE), whenever_cron.chomp)
      else # Otherwise, append the new cron entries after any existing ones
        [read_crontab, whenever_cron].join("\n\n")
      end
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