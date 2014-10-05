require 'whenever'
require 'test_case'
require 'mocha/setup'

module Whenever::TestHelpers
  protected
    def new_job(options={})
      Whenever::Job.new(options)
    end

    def parse_time(time = nil, task = nil, at = nil)
      Whenever::Output::Cron.new(time, task, at).time_in_cron_syntax
    end

    def two_hours
      "0 0,2,4,6,8,10,12,14,16,18,20,22 * * *"
    end

    def assert_days_and_hours_and_minutes_equals(expected, time)
      cron = parse_time(Whenever.seconds(2, :months), 'some task', time)
      minutes, hours, days, *garbage = cron.split(' ')
      assert_equal expected, [days, hours, minutes]
    end

    def assert_hours_and_minutes_equals(expected, time)
      cron = parse_time(Whenever.seconds(2, :days), 'some task', time)
      minutes, hours, *garbage = cron.split(' ')
      assert_equal expected, [hours, minutes]
    end

    def assert_minutes_equals(expected, time)
      cron = parse_time(Whenever.seconds(2, :hours), 'some task', time)
      assert_equal expected, cron.split(' ')[0]
    end
end

Whenever::TestCase.send(:include, Whenever::TestHelpers)
