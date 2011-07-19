require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class OutputAtTest < Test::Unit::TestCase
  
  context "weekday at a (single) given time" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every "weekday", :at => '5:02am' do
          command "blahblah"
        end
      file
    end
    
    should "output the command using that time" do
      assert_match '2 5 * * 1-5 blahblah', @output
    end
  end
  
  context "weekday at a multiple diverse times, via an array" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every "weekday", :at => %w(5:02am 3:52pm) do
          command "blahblah"
        end
      file
    end
    
    should "output the commands for both times given" do
      assert_match '2 5 * * 1-5 blahblah', @output
      assert_match '52 15 * * 1-5 blahblah', @output
    end
  end
  
  context "weekday at a multiple diverse times, comma separated" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every "weekday", :at => '5:02am, 3:52pm' do
          command "blahblah"
        end
      file
    end
    
    should "output the commands for both times given" do
      assert_match '2 5 * * 1-5 blahblah', @output
      assert_match '52 15 * * 1-5 blahblah', @output
    end
  end
  
  context "weekday at a multiple aligned times" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every "weekday", :at => '5:02am, 3:02pm' do
          command "blahblah"
        end
      file
    end
    
    should "output the command using one entry because the times are aligned" do
      assert_match '2 5,15 * * 1-5 blahblah', @output
    end
  end
  
  context "various days at a various aligned times" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every "mon,wed,fri", :at => '5:02am, 3:02pm' do
          command "blahblah"
        end
      file
    end
    
    should "output the command using one entry because the times are aligned" do
      assert_match '2 5,15 * * 1,3,5 blahblah', @output
    end
  end
  
  context "various days at a various aligned times using a runner" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        set :path, '/your/path'
        every "mon,wed,fri", :at => '5:02am, 3:02pm' do
          runner "blahblah"
        end
      file
    end
    
    should "output the runner using one entry because the times are aligned" do
      assert_match %(2 5,15 * * 1,3,5 cd /your/path && script/runner -e production 'blahblah'), @output
    end
  end
  
  context "various days at a various aligned times using a rake task" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        set :path, '/your/path'
        every "mon,wed,fri", :at => '5:02am, 3:02pm' do
          rake "blah:blah"
        end
      file
    end
    
    should "output the rake task using one entry because the times are aligned" do
      assert_match '2 5,15 * * 1,3,5 cd /your/path && RAILS_ENV=production bundle exec rake blah:blah --silent', @output
    end
  end
  
  context "A command every 1.month at very diverse times" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every [1.month, 1.day], :at => 'january 5:02am, june 17th at 2:22pm, june 3rd at 3:33am' do
          command "blahblah"
        end
      file
    end
    
    should "output 6 commands since none align" do
      # The 1.month commands
      assert_match '2 5 1 * * blahblah', @output
      assert_match '22 14 17 * * blahblah', @output
      assert_match '33 3 3 * * blahblah', @output
      
      # The 1.day commands
      assert_match '2 5 * * * blahblah', @output
      assert_match '22 14 * * * blahblah', @output
      assert_match '33 3 * * * blahblah', @output
    end
  end
  
  context "Multiple commands output every :reboot" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every :reboot do
          command "command_1"
          command "command_2"
        end
      file
    end
    
    should "output both commands @reboot" do
      assert_match "@reboot command_1", @output
      assert_match "@reboot command_2", @output
    end
  end
  
  context "Many different job types output every :day" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        set :path, '/your/path'
        every :daily do
          rake "blah:blah"
          runner "runner_1"
          command "command_1"
          runner "runner_2"
          command "command_2"
        end
      file
    end
    
    should "output all of the commands @daily" do
      assert_match '@daily cd /your/path && RAILS_ENV=production bundle exec rake blah:blah --silent', @output
      assert_match %(@daily cd /your/path && script/runner -e production 'runner_1'), @output
      assert_match '@daily command_1', @output
      assert_match %(@daily cd /your/path && script/runner -e production 'runner_2'), @output
      assert_match '@daily command_2', @output
    end
  end
  
  context "every 5 minutes but but starting at 1" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every 5.minutes, :at => 1 do
          command "blahblah"
        end
      file
    end
    
    should "output the command using that time" do
      assert_match '1,6,11,16,21,26,31,36,41,46,51,56 * * * * blahblah', @output
    end
  end

  context "every 4 minutes but starting at 2" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every 4.minutes, :at => 2 do
          command "blahblah"
        end
      file
    end
    
    should "output the command using that time" do
      assert_match '2,6,10,14,18,22,26,30,34,38,42,46,50,54,58 * * * * blahblah', @output
    end
  end

  context "every 3 minutes but starting at 7" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every 3.minutes, :at => 7 do
          command "blahblah"
        end
      file
    end
    
    should "output the command using that time" do
      assert_match '7,10,13,16,19,22,25,28,31,34,37,40,43,46,49,52,55,58 * * * * blahblah', @output
    end
  end

  context "every 2 minutes but starting at 27" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every 2.minutes, :at => 27 do
          command "blahblah"
        end
      file
    end
    
    should "output the command using that time" do
      assert_match '27,29,31,33,35,37,39,41,43,45,47,49,51,53,55,57,59 * * * * blahblah', @output
    end
  end
  
  context "using raw cron syntax" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every '0 0 27,31 * *' do
          command "blahblah"
        end
      file
    end
    
    should "output the command using the same cron syntax" do
      assert_match '0 0 27,31 * * blahblah', @output
    end
  end
  
end
