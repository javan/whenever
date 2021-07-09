require 'test_helper'

class OutputRandomAtTest < Whenever::TestCase
  test "pseudo random at for hour and day" do
    output = Whenever.cron \
    <<-file
      set :job_template, nil
      set :randomize, true
      every :day do
        command "blahblah"
      end
    file
    assert_match '34 2 * * * blahblah', output

    output = Whenever.cron \
    <<-file
      set :job_template, nil
      every :day, randomize: true do
        command "blah"
      end
    file
    assert_match '47 5 * * * blah', output

    output = Whenever.cron \
    <<-file
      set :job_template, nil
      set :randomize, true
      every :hour do
        command "blahblah"
      end
    file
    assert_match '34 * * * * blahblah', output

    output = Whenever.cron \
    <<-file
      set :job_template, nil
      every :hour, randomize: true do
        command "blah"
      end
    file
    assert_match '47 * * * * blah', output
  end
end
