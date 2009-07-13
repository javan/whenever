require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class OutputCommandTest < Test::Unit::TestCase
  
  context "A plain command" do
    setup do
      @output = Whenever.cron \
      <<-file
        every 2.hours do
          command "blahblah"
        end
      file
    end
    
    should "output the command" do
      assert_match /^.+ .+ .+ .+ blahblah$/, @output
    end
  end
  
  context "A command when the cron_log is set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :cron_log, 'logfile.log'
        every 2.hours do
          command "blahblah"
        end
      file
    end
    
    should "output the command with the log syntax appended" do
      assert_match /^.+ .+ .+ .+ blahblah >> logfile.log 2>&1$/, @output
    end
  end
  
  context "A command when the cron_log is set and the comand overrides it" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :cron_log, 'logfile.log'
        every 2.hours do
          command "blahblah", :cron_log => 'otherlog.log'
        end
      file
    end
    
    should "output the command with the log syntax appended" do
      assert_no_match /.+ .+ .+ .+ blahblah >> logfile.log 2>&1/, @output
      assert_match /^.+ .+ .+ .+ blahblah >> otherlog.log 2>&1$/, @output
    end
  end
  
  context "A command when the cron_log is set and the comand rejects it" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :cron_log, 'logfile.log'
        every 2.hours do
          command "blahblah", :cron_log => false
        end
      file
    end

    should "output the command without the log syntax appended" do
      assert_no_match /.+ .+ .+ .+ blahblah >> logfile.log 2>&1/, @output
      assert_match /^.+ .+ .+ .+ blahblah$/, @output
    end
  end
  
  context "A command when the cron_log is set and is overridden by the :set option" do
    setup do
      @output = Whenever.cron :set => 'cron_log=otherlog.log', :string => \
      <<-file
        set :cron_log, 'logfile.log'
        every 2.hours do
          command "blahblah"
        end
      file
    end

    should "output the otherlog.log as the log file" do
      assert_no_match /.+ .+ .+ .+ blahblah >> logfile.log 2>&1/, @output
      assert_match /^.+ .+ .+ .+ blahblah >> otherlog.log 2>&1/, @output
    end
  end
  
  context "An every statement with two commands in it" do
    setup do
      @output = Whenever.cron \
      <<-file
        every 1.hour do
          command "first"
          command "second"
        end
      file
    end

    should "output both commands" do
      assert_match "0 * * * * first", @output
      assert_match "0 * * * * second", @output
    end
  end
  
end