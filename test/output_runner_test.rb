require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class OutputRunnerTest < Test::Unit::TestCase
  
  context "A runner with path set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :path, '/my/path'
        every 2.hours do
          runner "blahblah"
        end
      file
    end
    
    should "output the runner using that path" do
      assert_match two_hours + ' /my/path/script/runner -e production "blahblah"', @output
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
      assert_match two_hours + ' /some/other/path/script/runner -e production "blahblah"', @output
    end
  end
  
  context "A runner with no path set and RAILS_ROOT defined" do
    setup do
      Whenever.stubs(:path).returns('/my/path')
      
      @output = Whenever.cron \
      <<-file
        every 2.hours do
          runner "blahblah"
        end
      file
    end
    
    should "output the runner using that path" do
      assert_match two_hours + ' /my/path/script/runner -e production "blahblah"', @output
    end
  end
  
  context "A runner with path set AND RAILS_ROOT defined" do
    setup do
      Whenever.stubs(:path).returns('/my/rails/path')
      
      @output = Whenever.cron \
      <<-file
        set :path, '/my/path'
        every 2.hours do
          runner "blahblah"
        end
      file
    end
    
    should "use the path" do
      assert_match two_hours + ' /my/path/script/runner -e production "blahblah"', @output
      assert_no_match /\/rails\/path/, @output
    end
  end
  
  context "A runner with no path set and no RAILS_ROOT defined" do
    setup do
      Whenever.stubs(:path).returns(nil)
      
      @input = <<-file
        every 2.hours do
          runner "blahblah"
        end
      file
    end
    
    should "raise an exception" do
      assert_raises ArgumentError do
        Whenever.cron(@input)
      end
    end
  end
  
  context "A runner with an environment set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :environment, :silly
        set :path, '/my/path'
        every 2.hours do
          runner "blahblah"
        end
      file
    end
    
    should "output the runner using that environment" do
      assert_match two_hours + ' /my/path/script/runner -e silly "blahblah"', @output
    end
  end
  
  context "A runner that overrides the environment set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :environment, :silly
        set :path, '/my/path'
        every 2.hours do
          runner "blahblah", :environment => :serious
        end
      file
    end
    
    should "output the runner using that environment" do
      assert_match two_hours + ' /my/path/script/runner -e serious "blahblah"', @output
    end
  end
  
end