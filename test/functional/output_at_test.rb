require 'test_helper'

class OutputAtTest < Whenever::TestCase
  test "weekday at a (single) given time" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      every "weekday", :at => '5:02am' do
        command "blahblah"
      end
    file

    assert_match '2 5 * * 1-5 blahblah', output
  end

  test "weekday at a multiple diverse times, via an array" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      every "weekday", :at => %w(5:02am 3:52pm) do
        command "blahblah"
      end
    file

    assert_match '2 5 * * 1-5 blahblah', output
    assert_match '52 15 * * 1-5 blahblah', output
  end

  test "weekday at a multiple diverse times, comma separated" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      every "weekday", :at => '5:02am, 3:52pm' do
        command "blahblah"
      end
    file

    assert_match '2 5 * * 1-5 blahblah', output
    assert_match '52 15 * * 1-5 blahblah', output
  end

  test "weekday at a multiple aligned times" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      every "weekday", :at => '5:02am, 3:02pm' do
        command "blahblah"
      end
    file

    assert_match '2 5,15 * * 1-5 blahblah', output
  end

  test "various days at a various aligned times" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      every "mon,wed,fri", :at => '5:02am, 3:02pm' do
        command "blahblah"
      end
    file

    assert_match '2 5,15 * * 1,3,5 blahblah', output
  end

  test "various days at a various aligned times using a runner" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      set :path, '/your/path'
      every "mon,wed,fri", :at => '5:02am, 3:02pm' do
        runner "Worker.perform_async(1.day.ago)"
      end
    file

    assert_match %(2 5,15 * * 1,3,5 cd /your/path && bundle exec script/runner -e production 'Worker.perform_async(1.day.ago)'), output
  end

  test "various days at a various aligned times using a rake task" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      set :path, '/your/path'
      every "mon,wed,fri", :at => '5:02am, 3:02pm' do
        rake "blah:blah"
      end
    file

    assert_match '2 5,15 * * 1,3,5 cd /your/path && RAILS_ENV=production bundle exec rake blah:blah --silent', output
  end

  test "A command every 1.month at very diverse times" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      every [1.month, 1.day], :at => 'january 5:02am, june 17th at 2:22pm, june 3rd at 3:33am' do
        command "blahblah"
      end
    file

    # The 1.month commands
    assert_match '2 5 1 * * blahblah', output
    assert_match '22 14 17 * * blahblah', output
    assert_match '33 3 3 * * blahblah', output

    # The 1.day commands
    assert_match '2 5 * * * blahblah', output
    assert_match '22 14 * * * blahblah', output
    assert_match '33 3 * * * blahblah', output
  end

  test "Multiple commands output every :reboot" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      every :reboot do
        command "command_1"
        command "command_2"
      end
    file

    assert_match "@reboot command_1", output
    assert_match "@reboot command_2", output
  end

  test "Many different job types output every :day" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      set :path, '/your/path'
      every :daily do
        rake "blah:blah"
        runner "runner_1"
        command "command_1"
        runner "runner_2"
        command "command_2"
      end
    file

    assert_match '@daily cd /your/path && RAILS_ENV=production bundle exec rake blah:blah --silent', output
    assert_match %(@daily cd /your/path && bundle exec script/runner -e production 'runner_1'), output
    assert_match '@daily command_1', output
    assert_match %(@daily cd /your/path && bundle exec script/runner -e production 'runner_2'), output
    assert_match '@daily command_2', output
  end

  test "every 5 minutes but but starting at 1" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      every 5.minutes, :at => 1 do
        command "blahblah"
      end
    file

    assert_match '1,6,11,16,21,26,31,36,41,46,51,56 * * * * blahblah', output
  end

  test "every 4 minutes but starting at 2" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      every 4.minutes, :at => 2 do
        command "blahblah"
      end
    file

    assert_match '2,6,10,14,18,22,26,30,34,38,42,46,50,54,58 * * * * blahblah', output
  end

  test "every 3 minutes but starting at 7" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      every 3.minutes, :at => 7 do
        command "blahblah"
      end
    file


    assert_match '7,10,13,16,19,22,25,28,31,34,37,40,43,46,49,52,55,58 * * * * blahblah', output
  end

  test "every 2 minutes but starting at 27" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      every 2.minutes, :at => 27 do
        command "blahblah"
      end
    file

    assert_match '27,29,31,33,35,37,39,41,43,45,47,49,51,53,55,57,59 * * * * blahblah', output
  end

  test "using raw cron syntax" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      every '0 0 27,31 * *' do
        command "blahblah"
      end
    file

    assert_match '0 0 27,31 * * blahblah', output
  end

  test "using custom Chronic configuration to specify time using 24 hour clock" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      set :chronic_options, :hours24 => true
      every 1.day, :at => '03:00' do
        command "blahblah"
      end
    file

    assert_match '0 3 * * * blahblah', output
  end

  test "using custom Chronic configuration to specify date using little endian preference" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      set :chronic_options, :endian_precedence => :little
      every 1.month, :at => '02/03 10:15' do
        command "blahblah"
      end
    file

    assert_match '15 10 2 * * blahblah', output
  end

  test "using custom Chronic configuration to specify time using 24 hour clock and date using little endian preference" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      set :chronic_options, :hours24 => true, :endian_precedence => :little
      every 1.month, :at => '01/02 04:30' do
        command "blahblah"
      end
    file

    assert_match '30 4 1 * * blahblah', output
  end
end
