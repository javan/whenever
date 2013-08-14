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

  context "A plain command with a job_template using a normal parameter" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, "/bin/bash -l -c 'cd :path && :job'"
        every 2.hours do
          set :path, "/tmp"
          command "blahblah"
        end
      file
    end

    should "output the command using that job_template" do
      assert_match /^.+ .+ .+ .+ \/bin\/bash -l -c 'cd \/tmp \&\& blahblah'$/, @output
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

  context "A plain command that overrides the job_template set using a parameter" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, "/bin/bash -l -c 'cd :path && :job'"
        every 2.hours do
          set :path, "/tmp"
          command "blahblah", :job_template => "/bin/sh -l -c 'cd :path && :job'"
        end
      file
    end

    should "output the command using that job_template" do
      assert_match /^.+ .+ .+ .+ \/bin\/sh -l -c 'cd \/tmp && blahblah'$/, @output
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

  context "A runner for an app with bin/rails" do
    setup do
      Whenever.expects(:path).at_least_once.returns('/my/path')
      Whenever.expects(:bin_rails?).returns(true)
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every 2.hours do
          runner 'blahblah'
        end
      file
    end

    should "use a script/rails runner job by default" do
      assert_match two_hours + %( cd /my/path && bin/rails runner -e production 'blahblah'), @output
    end
  end

  context "A runner for an app with script/rails" do
    setup do
      Whenever.expects(:path).at_least_once.returns('/my/path')
      Whenever.expects(:script_rails?).returns(true)
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every 2.hours do
          runner 'blahblah'
        end
      file
    end

    should "use a script/rails runner job by default" do
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

  context "A rake command that sets the environment variable" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        set :path, '/my/path'
        set :environment_variable, 'RAKE_ENV'
        every 2.hours do
          rake "blahblah"
        end
      file
    end

    should "output the rake command using that environment variable" do
      assert_match two_hours + ' cd /my/path && RAKE_ENV=production bundle exec rake blahblah --silent', @output
    end
  end

  context "A rake command that overrides the environment variable" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        set :path, '/my/path'
        set :environment_variable, 'RAKE_ENV'
        every 2.hours do
          rake "blahblah", :environment_variable => 'SOME_ENV'
        end
      file
    end

    should "output the rake command using that environment variable" do
      assert_match two_hours + ' cd /my/path && SOME_ENV=production bundle exec rake blahblah --silent', @output
    end
  end

    # script

  context "A script command with path set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        set :path, '/my/path'
        every 2.hours do
          script "blahblah"
        end
      file
    end

    should "output the script command using that path" do
      assert_match two_hours + ' cd /my/path && RAILS_ENV=production bundle exec script/blahblah', @output
    end
  end

  context "A script command for a non-bundler app" do
    setup do
      Whenever.expects(:path).at_least_once.returns('/my/path')
      Whenever.expects(:bundler?).returns(false)
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every 2.hours do
          script 'blahblah'
        end
      file
    end

    should "not use invoke through bundler" do
      assert_match two_hours + ' cd /my/path && RAILS_ENV=production script/blahblah', @output
    end
  end

  context "A script command that uses output" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        set :output, '/log/file'
        set :path, '/my/path'
        every 2.hours do
          script "blahblah", :path => '/some/other/path'
        end
      file
    end

    should "output the script command using that path" do
      assert_match two_hours + ' cd /some/other/path && RAILS_ENV=production bundle exec script/blahblah >> /log/file 2>&1', @output
    end
  end

  context "A script command that uses an environment variable" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        set :environment_variable, 'RAKE_ENV'
        set :path, '/my/path'
        every 2.hours do
          script "blahblah"
        end
      file
    end

    should "output the script command using that environment variable" do
      assert_match two_hours + ' cd /my/path && RAKE_ENV=production bundle exec script/blahblah', @output
    end
  end

end
