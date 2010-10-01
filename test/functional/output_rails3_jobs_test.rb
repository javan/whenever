require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class OutputDefaultDefinedJobsTest < Test::Unit::TestCase
  
  # runner
  
  context "A Rails3 runner with path set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :path, '/my/path'
        every 2.hours do
          rails3_runner 'blahblah'
        end
      file
    end
    
    should "output the Rails 3 runner using that path" do
      assert_match two_hours + %( cd /my/path && rails runner -e production 'blahblah'), @output
    end
  end
  
  context "A Rails 3 runner that overrides the path set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :path, '/my/path'
        every 2.hours do
          rails3_runner "blahblah", :path => '/some/other/path'
        end
      file
    end
    
    should "output the Rails 3 runner using that path" do
      assert_match two_hours + %( cd /some/other/path && rails runner -e production 'blahblah'), @output
    end
  end
  
end