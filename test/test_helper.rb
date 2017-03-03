require 'whenever'
require 'test_case'
require 'mocha/setup'

module Whenever::TestHelpers
  protected
    def new_job(options={})
      Whenever::Job.new(options)
    end

    def parse_time(time = nil, task = nil, at = nil, options = {})
      Whenever::Output::Cron.new(time, task, at, options).time_in_cron_syntax
    end

    def two_hours
      "0 0,2,4,6,8,10,12,14,16,18,20,22 * * *"
    end

    def assert_months_and_days_and_hours_and_minutes_equals(expected, time, options = {})
      cron = parse_time(Whenever.seconds(1, :year), 'some task', time, options)
      minutes, hours, days, months = cron.split(' ')
      assert_equal expected, [months, days, hours, minutes]
    end

    def assert_days_and_hours_and_minutes_equals(expected, time, options = {})
      cron = parse_time(Whenever.seconds(2, :months), 'some task', time, options)
      minutes, hours, days, _ = cron.split(' ')
      assert_equal expected, [days, hours, minutes]
    end

    def assert_hours_and_minutes_equals(expected, time, options = {})
      cron = parse_time(Whenever.seconds(2, :days), 'some task', time, options)
      minutes, hours, _ = cron.split(' ')
      assert_equal expected, [hours, minutes]
    end

    def assert_minutes_equals(expected, time, options = {})
      cron = parse_time(Whenever.seconds(2, :hours), 'some task', time, options)
      assert_equal expected, cron.split(' ')[0]
    end

    def lines_without_empty_line(lines)
      lines.map { |line| line.chomp }.reject { |line| line.empty? }
    end
end

Whenever::TestCase.send(:include, Whenever::TestHelpers)
