require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class OutputAtTest < Test::Unit::TestCase
  
  context "weekday at a (single) given time" do
    setup do
      @output = Whenever.cron \
      <<-file
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
        set :path, '/your/path'
        every "mon,wed,fri", :at => '5:02am, 3:02pm' do
          runner "blahblah"
        end
      file
    end
    
    should "output the runner using one entry because the times are aligned" do
      assert_match '2 5,15 * * 1,3,5 /your/path/script/runner -e production "blahblah"', @output
    end
  end
  
  context "various days at a various aligned times using a rake task" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :path, '/your/path'
        every "mon,wed,fri", :at => '5:02am, 3:02pm' do
          rake "blah:blah"
        end
      file
    end
    
    should "output the rake task using one entry because the times are aligned" do
      assert_match '2 5,15 * * 1,3,5 cd /your/path && RAILS_ENV=production /usr/bin/env rake blah:blah', @output
    end
  end
  
  context "A command every 1.month at very diverse times" do
    setup do
      @output = Whenever.cron \
      <<-file
        every [1.month, 1.day], :at => 'beginning of the month at 5:02am, june 17th at 2:22pm, june 3rd at 3:33am' do
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
  
end
