require 'test_helper'

class OutputRedirectionTest < Whenever::TestCase
  test "command when the output is set to nil" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      set :output, nil
      every 2.hours do
        command "blahblah"
      end
    file

    assert_match(/^.+ .+ .+ .+ blahblah >> \/dev\/null 2>&1$/, output)
  end


  test "command when the output is set" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      set :output, 'logfile.log'
      every 2.hours do
        command "blahblah"
      end
    file

    assert_match(/^.+ .+ .+ .+ blahblah >> logfile.log 2>&1$/, output)
  end

  test "command when the error and standard output is set by the command" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      every 2.hours do
        command "blahblah", :output => {:standard => 'dev_null', :error => 'dev_err'}
      end
    file

    assert_match(/^.+ .+ .+ .+ blahblah >> dev_null 2>> dev_err$/, output)
  end

  test "command when the output is set and the comand overrides it" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      set :output, 'logfile.log'
      every 2.hours do
        command "blahblah", :output => 'otherlog.log'
      end
    file

    assert_no_match(/.+ .+ .+ .+ blahblah >> logfile.log 2>&1/, output)
    assert_match(/^.+ .+ .+ .+ blahblah >> otherlog.log 2>&1$/, output)
  end

  test "command when the output is set and the comand overrides with standard and error" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      set :output, 'logfile.log'
      every 2.hours do
        command "blahblah", :output => {:error => 'dev_err', :standard => 'dev_null' }
      end
    file

    assert_no_match(/.+ .+ .+ .+ blahblah >> logfile.log 2>&1/, output)
    assert_match(/^.+ .+ .+ .+ blahblah >> dev_null 2>> dev_err$/, output)
  end

  test "command when the output is set and the comand rejects it" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      set :output, 'logfile.log'
      every 2.hours do
        command "blahblah", :output => false
      end
    file

    assert_no_match(/.+ .+ .+ .+ blahblah >> logfile.log 2>&1/, output)
    assert_match(/^.+ .+ .+ .+ blahblah$/, output)
  end

  test "command when the output is set and is overridden by the :set option" do
    output = Whenever.cron :set => 'output=otherlog.log', :string => \
    <<-file
      set :job_template, nil
      set :output, 'logfile.log'
      every 2.hours do
        command "blahblah"
      end
    file

    assert_no_match(/.+ .+ .+ .+ blahblah >> logfile.log 2>&1/, output)
    assert_match(/^.+ .+ .+ .+ blahblah >> otherlog.log 2>&1/, output)
  end

  test "command when the error and standard output is set" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      set :output, {:error => 'dev_err', :standard => 'dev_null' }
      every 2.hours do
        command "blahblah"
      end
    file

    assert_match(/^.+ .+ .+ .+ blahblah >> dev_null 2>> dev_err$/, output)
  end

  test "command when error output is set" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      set :output, {:error => 'dev_null'}
      every 2.hours do
        command "blahblah"
      end
    file

    assert_match(/^.+ .+ .+ .+ blahblah 2>> dev_null$/, output)
  end

  test "command when the standard output is set" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      set :output, {:standard => 'dev_out'}
      every 2.hours do
        command "blahblah"
      end
    file

    assert_match(/^.+ .+ .+ .+ blahblah >> dev_out$/, output)
  end

  test "command when error output is set by the command" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      every 2.hours do
        command "blahblah", :output => {:error => 'dev_err'}
      end
    file

    assert_match(/^.+ .+ .+ .+ blahblah 2>> dev_err$/, output)
  end

  test "command when standard output is set by the command" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      every 2.hours do
        command "blahblah", :output => {:standard => 'dev_out'}
      end
    file

    assert_match(/^.+ .+ .+ .+ blahblah >> dev_out$/, output)
  end

  test "command when standard output is set to nil" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      every 2.hours do
        command "blahblah", :output => {:standard => nil}
      end
    file

    assert_match(/^.+ .+ .+ .+ blahblah > \/dev\/null$/, output)
  end

  test "command when standard error is set to nil" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      every 2.hours do
        command "blahblah", :output => {:error => nil}
      end
    file

    assert_match(/^.+ .+ .+ .+ blahblah 2> \/dev\/null$/, output)
  end

  test "command when standard output and standard error is set to nil" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      every 2.hours do
        command "blahblah", :output => {:error => nil, :standard => nil}
      end
    file

    assert_match(/^.+ .+ .+ .+ blahblah > \/dev\/null 2>&1$/, output)
  end

  test "command when standard output is set and standard error is set to nil" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      every 2.hours do
        command "blahblah", :output => {:error => nil, :standard => 'my.log'}
      end
    file

    assert_match(/^.+ .+ .+ .+ blahblah >> my.log 2> \/dev\/null$/, output)
  end

  test "command when standard output is nil and standard error is set" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      every 2.hours do
        command "blahblah", :output => {:error => 'my_error.log', :standard => nil}
      end
    file

    assert_match(/^.+ .+ .+ .+ blahblah >> \/dev\/null 2>> my_error.log$/, output)
  end

  test "command when the deprecated :cron_log is set" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      set :cron_log, "cron.log"
      every 2.hours do
        command "blahblah"
      end
    file

    assert_match(/^.+ .+ .+ .+ blahblah >> cron.log 2>&1$/, output)
  end


  test "a command when the standard output is set to a lambda" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      set :output, lambda { "2>&1 | logger -t whenever_cron" }
      every 2.hours do
        command "blahblah"
      end
    file

    assert_match(/^.+ .+ .+ .+ blahblah 2>&1 | logger -t whenever_cron$/, output)
  end

  test "a command when all output is set to a MailCommand" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      set :output, Whenever::Output::MailCommand.new(to: 'admin@example.com', from: 'cron@example.com', subject: "Something went wrong in your cron job")
      every 2.hours do
        command "blahblah"
      end
    file

    assert_match /^.+ .+ .+ .+ blahblah >> >\( mail -E -s "Something went wrong in your cron job" -r "cron@example.com" admin@example.com \) 2>&1$/, output
  end

  test "a command when all output is set to a LoggerCommand" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      set :output, Whenever::Output::LoggerCommand.new(tag: :whenever_cron)
      every 2.hours do
        command "blahblah"
      end
    file

    assert_match /^.+ .+ .+ .+ blahblah >> >\( logger -t whenever_cron \) 2>&1$/, output
  end

  test "a command when all output is set to a TeeCommand" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      mail_command = Whenever::Output::MailCommand.new(to: 'admin@example.com', from: 'cron@example.com', subject: "Something went wrong in your cron job")
      logger_command = Whenever::Output::LoggerCommand.new(tag: :whenever_cron)
      set :output, Whenever::Output::TeeCommand.new(mail_command, "log/whenever.log", logger_command)
      every 2.hours do
        command "blahblah"
      end
    file

    assert_match /^.+ .+ .+ .+ blahblah >> >\( tee >\( mail -E -s "Something went wrong in your cron job" -r "cron@example.com" admin@example.com \) log\/whenever\.log >\( logger -t whenever_cron \) > \/dev\/null \) 2>&1$/, output
  end

  test "a command when the standard output is omitted and standard error is set to a Command" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      set :output, { error: Whenever::Output::LoggerCommand.new(tag: :whenever_cron) }
      every 2.hours do
        command "blahblah"
      end
    file

    assert_match /^.+ .+ .+ .+ blahblah 2>> >\( logger -t whenever_cron \)$/, output
  end

  test "a command when the standard output is set to nil and standard error is set to a Command" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      set :output, { standard: nil, error: Whenever::Output::LoggerCommand.new(tag: :whenever_cron) }
      every 2.hours do
        command "blahblah"
      end
    file

    assert_match /^.+ .+ .+ .+ blahblah >> \/dev\/null 2>> >\( logger -t whenever_cron \)$/, output
  end
end
