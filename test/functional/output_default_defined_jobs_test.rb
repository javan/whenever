require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class OutputDefaultDefinedJobsTest < Test::Unit::TestCase
  
  # command
  
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
  
  # runner
  
  context "A runner with path set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :path, '/my/path'
        every 2.hours do
          runner 'blahblah'
        end
      file
    end
    
    should "output the runner using that path" do
      assert_match two_hours + %( cd /my/path && script/runner -e production 'blahblah'), @output
    end
  end
  
  context "A runner that overrides the path set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :path, '/my/path'
        every 2.hours do
          runner "blahblah", :path => '/some/other/path'
        end
      file
    end
    
    should "output the runner using that path" do
      assert_match two_hours + %( cd /some/other/path && script/runner -e production 'blahblah'), @output
    end
  end
  
  # rake
  
  context "A rake command with path set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :path, '/my/path'
        every 2.hours do
          rake "blahblah"
        end
      file
    end
    
    should "output the rake command using that path" do
      assert_match two_hours + ' cd /my/path && RAILS_ENV=production rake blahblah --silent', @output
    end
  end
  
  context "A rake command that overrides the path set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :path, '/my/path'
        every 2.hours do
          rake "blahblah", :path => '/some/other/path'
        end
      file
    end
    
    should "output the rake command using that path" do
      assert_match two_hours + ' cd /some/other/path && RAILS_ENV=production rake blahblah --silent', @output
    end
  end
  
end