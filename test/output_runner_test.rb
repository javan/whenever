require 'test_helper'

class OutputRunnerTest < Test::Unit::TestCase
  
  context "A runner with runner_path set" do
    setup do
      @output = load_whenever_output \
      <<-file
        set :runner_path, '/my/path'
        every 2.hours do
          runner "blahblah"
        end
      file
    end
    
    should "output the runner using that path" do
      assert_match two_hours + ' /my/path/script/runner -e production "blahblah"', @output
    end
  end
  
  context "A runner with no runner_path set and RAILS_ROOT defined" do
    setup do
      Whenever::Job::Runner.stubs(:rails_root).returns('/my/path')
      
      @output = load_whenever_output \
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
  
  context "A runner with runner_path set AND RAILS_ROOT defined" do
    setup do
      Whenever::Job::Runner.stubs(:rails_root).returns('/my/path')
      
      @output = load_whenever_output \
      <<-file
        set :runner_path, '/my/path'
        every 2.hours do
          runner "blahblah"
        end
      file
    end
    
    should "use the runner_path" do
      assert_match two_hours + ' /my/path/script/runner -e production "blahblah"', @output
      assert_no_match /\/rails\/path/, @output
    end
  end
  
  context "A runner with no runner_path set and no RAILS_ROOT defined" do
    setup do
      Whenever::Job::Runner.stubs(:rails_root).returns(nil)
      
      @input = <<-file
        every 2.hours do
          runner "blahblah"
        end
      file
    end
    
    should "raise an exception" do
      assert_raises ArgumentError do
        load_whenever_output(@input)
      end
    end
  end
  
end