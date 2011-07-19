require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class OutputDefaultDefinedJobsTest < Test::Unit::TestCase
  
  # command
  
  context "A plain command with the job template set to nil" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every 2.hours do
          command "blahblah"
        end
      file
    end
    
    should "output the command" do
      assert_match /^.+ .+ .+ .+ blahblah$/, @output
    end
  end
  
  context "A plain command with no job template set" do
    setup do
      @output = Whenever.cron \
      <<-file
        every 2.hours do
          command "blahblah"
        end
      file
    end
    
    should "output the command with the default job template" do
      assert_match /^.+ .+ .+ .+ \/bin\/bash -l -c 'blahblah'$/, @output
    end
  end
  
  context "A plain command that overrides the job_template set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, "/bin/bash -l -c ':job'"
        every 2.hours do
          command "blahblah", :job_template => "/bin/sh -l -c ':job'"
        end
      file
    end
    
    should "output the command using that job_template" do
      assert_match /^.+ .+ .+ .+ \/bin\/sh -l -c 'blahblah'$/, @output
      assert_no_match /bash/, @output
    end
  end
  
  context "A plain command that is conditional on default environent and path" do
    setup do
      Whenever.expects(:path).at_least_once.returns('/what/you/want')
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        if environment == 'production' && path == '/what/you/want'
          every 2.hours do
            command "blahblah"
          end
        end
      file
    end
    
    should "output the command" do
      assert_match /blahblah/, @output
    end
  end

  # runner
  
  context "A runner with path set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
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
        set :job_template, nil
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
  
  context "A runner for a Rails 3 app" do
    setup do
      Whenever.expects(:path).at_least_once.returns('/my/path')
      Whenever.expects(:rails3?).returns(true)
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every 2.hours do
          runner 'blahblah'
        end
      file
    end
    
    should "use the Rails 3 runner job by default" do
      assert_match two_hours + %( cd /my/path && script/rails runner -e production 'blahblah'), @output
    end
  end
  
  # rake
  
  context "A rake command with path set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        set :path, '/my/path'
        every 2.hours do
          rake "blahblah"
        end
      file
    end
    
    should "output the rake command using that path" do
      assert_match two_hours + ' cd /my/path && RAILS_ENV=production bundle exec rake blahblah --silent', @output
    end
  end

  context "A rake for a non-bundler app" do
    setup do
      Whenever.expects(:path).at_least_once.returns('/my/path')
      Whenever.expects(:bundler?).returns(false)
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every 2.hours do
          rake 'blahblah'
        end
      file
    end

    should "not use invoke through bundler" do
      assert_match two_hours + ' cd /my/path && RAILS_ENV=production rake blahblah --silent', @output
    end
  end
  
  context "A rake command that overrides the path set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        set :path, '/my/path'
        every 2.hours do
          rake "blahblah", :path => '/some/other/path'
        end
      file
    end
    
    should "output the rake command using that path" do
      assert_match two_hours + ' cd /some/other/path && RAILS_ENV=production bundle exec rake blahblah --silent', @output
    end
  end
  
end