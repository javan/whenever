require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class OutputRedirectionTest < Test::Unit::TestCase

  context "A command when the output is set to nil" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        set :output, nil
        every 2.hours do
          command "blahblah"
        end
      file
    end
  
    should "output the command with the log syntax appended" do
      assert_match /^.+ .+ .+ .+ blahblah >> \/dev\/null 2>&1$/, @output
    end
  end


  context "A command when the output is set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        set :output, 'logfile.log'
        every 2.hours do
          command "blahblah"
        end
      file
    end
  
    should "output the command with the log syntax appended" do
      assert_match /^.+ .+ .+ .+ blahblah >> logfile.log 2>&1$/, @output
    end
  end

  context "A command when the error and standard output is set by the command" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every 2.hours do
          command "blahblah", :output => {:standard => 'dev_null', :error => 'dev_err'}
        end
      file
    end

    should "output the command without the log syntax appended" do
      assert_match /^.+ .+ .+ .+ blahblah >> dev_null 2>> dev_err$/, @output
    end
  end

  context "A command when the output is set and the comand overrides it" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        set :output, 'logfile.log'
        every 2.hours do
          command "blahblah", :output => 'otherlog.log'
        end
      file
    end
  
    should "output the command with the command syntax appended" do
      assert_no_match /.+ .+ .+ .+ blahblah >> logfile.log 2>&1/, @output
      assert_match /^.+ .+ .+ .+ blahblah >> otherlog.log 2>&1$/, @output
    end
  end

  context "A command when the output is set and the comand overrides with standard and error" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        set :output, 'logfile.log'
        every 2.hours do
          command "blahblah", :output => {:error => 'dev_err', :standard => 'dev_null' }
        end
      file
    end
  
    should "output the command with the overridden redirection syntax appended" do
      assert_no_match /.+ .+ .+ .+ blahblah >> logfile.log 2>&1/, @output
      assert_match /^.+ .+ .+ .+ blahblah >> dev_null 2>> dev_err$/, @output
    end
  end

  context "A command when the output is set and the comand rejects it" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        set :output, 'logfile.log'
        every 2.hours do
          command "blahblah", :output => false
        end
      file
    end

    should "output the command without the log syntax appended" do
      assert_no_match /.+ .+ .+ .+ blahblah >> logfile.log 2>&1/, @output
      assert_match /^.+ .+ .+ .+ blahblah$/, @output
    end
  end

  context "A command when the output is set and is overridden by the :set option" do
    setup do
      @output = Whenever.cron :set => 'output=otherlog.log', :string => \
      <<-file
        set :job_template, nil
        set :output, 'logfile.log'
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

  context "A command when the error and standard output is set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        set :output, {:error => 'dev_err', :standard => 'dev_null' }
        every 2.hours do
          command "blahblah"
        end
      file
    end

    should "output the command without the redirection syntax appended" do
      assert_match /^.+ .+ .+ .+ blahblah >> dev_null 2>> dev_err$/, @output
    end
  end

  context "A command when error output is set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        set :output, {:error => 'dev_null'}
        every 2.hours do
          command "blahblah"
        end
      file
    end

    should "output the command without the standard error syntax appended" do
      assert_match /^.+ .+ .+ .+ blahblah 2>> dev_null$/, @output
    end
  end

  context "A command when the standard output is set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        set :output, {:standard => 'dev_out'}
        every 2.hours do
          command "blahblah"
        end
      file
    end

    should "output the command with standard output syntax appended" do
      assert_match /^.+ .+ .+ .+ blahblah >> dev_out$/, @output
    end
  end

  context "A command when error output is set by the command" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every 2.hours do
          command "blahblah", :output => {:error => 'dev_err'}
        end
      file
    end

    should "output the command without the log syntax appended" do
      assert_match /^.+ .+ .+ .+ blahblah 2>> dev_err$/, @output
    end
  end

  context "A command when standard output is set by the command" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every 2.hours do
          command "blahblah", :output => {:standard => 'dev_out'}
        end
      file
    end

    should "output the command without the log syntax appended" do
      assert_match /^.+ .+ .+ .+ blahblah >> dev_out$/, @output
    end
  end

  context "A command when standard output is set to nil" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every 2.hours do
          command "blahblah", :output => {:standard => nil}
        end
      file
    end

    should "output the command with stdout directed to /dev/null" do
      assert_match /^.+ .+ .+ .+ blahblah > \/dev\/null$/, @output
    end
  end

  context "A command when standard error is set to nil" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every 2.hours do
          command "blahblah", :output => {:error => nil}
        end
      file
    end

    should "output the command with stderr directed to /dev/null" do
      assert_match /^.+ .+ .+ .+ blahblah 2> \/dev\/null$/, @output
    end
  end

  context "A command when standard output and standard error is set to nil" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every 2.hours do
          command "blahblah", :output => {:error => nil, :standard => nil}
        end
      file
    end

    should "output the command with stderr directed to /dev/null" do
      assert_match /^.+ .+ .+ .+ blahblah > \/dev\/null 2>&1$/, @output
    end
  end

  context "A command when standard output is set and standard error is set to nil" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every 2.hours do
          command "blahblah", :output => {:error => nil, :standard => 'my.log'}
        end
      file
    end

    should "output the command with stderr directed to /dev/null" do
      assert_match /^.+ .+ .+ .+ blahblah >> my.log 2> \/dev\/null$/, @output
    end
  end

  context "A command when standard output is nil and standard error is set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        every 2.hours do
          command "blahblah", :output => {:error => 'my_error.log', :standard => nil}
        end
      file
    end

    should "output the command with stderr directed to /dev/null" do
      assert_match /^.+ .+ .+ .+ blahblah >> \/dev\/null 2>> my_error.log$/, @output
    end
  end

  context "A command when the deprecated :cron_log is set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        set :cron_log, "cron.log"
        every 2.hours do
          command "blahblah"
        end
      file
    end

    should "output the command with with the stdout and stderr going to the log" do
      assert_match /^.+ .+ .+ .+ blahblah >> cron.log 2>&1$/, @output
    end
  end


  context "A command when the standard output is set to a lambda" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :job_template, nil
        set :output, lambda { "2>&1 | logger -t whenever_cron" }
        every 2.hours do
          command "blahblah"
        end
      file
    end

    should "output the command by result of the lambda evaluated" do
      assert_match /^.+ .+ .+ .+ blahblah 2>&1 | logger -t whenever_cron$/, @output
    end
  end

end
