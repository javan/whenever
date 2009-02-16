namespace :whenever do

  desc "outputs cron"
  task :output_cron do
    puts Whenever.cron(:file => "config/schedule.rb")
  end
  
  desc "writes cron"
  task :write_cron do
    require 'tempfile'
    cron_output = Whenever.cron(:file => "config/schedule.rb")
    
    tmp_cron_file = Tempfile.new('whenever_tmp_cron').path
    File.open(tmp_cron_file, File::WRONLY | File::APPEND) do |file|
      file << cron_output
    end
    sh "crontab #{tmp_cron_file}"
    puts "[write] crontab file updated"
  end

end