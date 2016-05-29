require 'test_helper'

class OutputDefinedJobTest < Whenever::TestCase
  test "defined job with a :task" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      job_type :some_job, "before :task after"
      every 2.hours do
        some_job "during"
      end
    file

    assert_match(/^.+ .+ .+ .+ before during after$/, output)
  end

  test "defined job with a :task and some options" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      job_type :some_job, "before :task after :option1 :option2"
      every 2.hours do
        some_job "during", :option1 => 'happy', :option2 => 'birthday'
      end
    file

    assert_match(/^.+ .+ .+ .+ before during after happy birthday$/, output)
  end

  test "defined job with a :task and an option where the option is set globally" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      job_type :some_job, "before :task after :option1"
      set :option1, 'happy'
      every 2.hours do
        some_job "during"
      end
    file

    assert_match(/^.+ .+ .+ .+ before during after happy$/, output)
  end

  test "defined job with a :task and an option where the option is set globally and locally" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      job_type :some_job, "before :task after :option1"
      set :option1, 'global'
      every 2.hours do
        some_job "during", :option1 => 'local'
      end
    file

    assert_match(/^.+ .+ .+ .+ before during after local$/, output)
  end

  test "defined job with a :task and an option that is not set" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      job_type :some_job, "before :task after :option1"
      every 2.hours do
        some_job "during", :option2 => 'happy'
      end
    file

    assert_match(/^.+ .+ .+ .+ before during after :option1$/, output)
  end

  test "defined job that uses a :path where none is explicitly set" do
    Whenever.stubs(:path).returns('/my/path')

    output = Whenever.cron \
    <<-file
      set :job_template, nil
      job_type :some_job, "cd :path && :task"
      every 2.hours do
        some_job 'blahblah'
      end
    file

    assert_match two_hours + %( cd /my/path && blahblah), output
  end
end
