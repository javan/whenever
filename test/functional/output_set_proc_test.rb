require 'test_helper'

class OutputSetProcTest < Whenever::TestCase

  test "Variables which is dynamically set by proc" do
    output = Whenever.cron \
    <<-file
      set :lock_file_name , proc { @options[:task] }
      set :job_template, "/bin/bash -l -c 'cd :path && setlock -n /var/run/:lock_file_name  :job'"
      every 2.hours do
        set :path, "/tmp"
        command "blahblah"
      end
    file

    assert_match /setlock -n \/var\/run\/blahblah/, output
  end

  test "Variables which is dynamically set by lambda" do
    output = Whenever.cron \
    <<-file
      set :lock_file_name , lambda { |x| @options[:task] }
      set :job_template, "/bin/bash -l -c 'cd :path && setlock -n /var/run/:lock_file_name  :job'"
      every 2.hours do
        set :path, "/tmp"
        command "blahblah"
      end
    file

    assert_match /setlock -n \/var\/run\/blahblah/, output
  end

  test "Variables which is dynamically set by proc can be overwritten by command set" do
    output = Whenever.cron \
    <<-file
      set :lock_file_name , proc { @options[:task] }
      set :job_template, "/bin/bash -l -c 'cd :path && setlock -n /var/run/:lock_file_name  :job'"
      every 2.hours do
        set :path, "/tmp"
        command "blahblah", :lock_file_name  => "custom_lock"
      end
    file

    assert_match /setlock -n \/var\/run\/custom_lock/, output
  end

end
