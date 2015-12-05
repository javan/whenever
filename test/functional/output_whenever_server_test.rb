require 'test_helper'

class OutputWheneverServer < Whenever::TestCase
  test 'command when the redis_options is set' do
    output = Whenever.cron \
    <<-file
      set :redis_options, url: 'redis://localhost:6379/1'
      every :hour do
        set :path, "/tmp"
        command "blahblah"
      end
    file

    assert_match "0 * * * * /bin/bash -l -c 'cd /tmp && if whenever_server >> /dev/null ; then blahblah ; fi'", output
  end
end