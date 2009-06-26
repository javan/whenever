require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class CronTest < Test::Unit::TestCase

  context "When parsing time in minutes" do
    should "raise if less than 1 minute" do
      assert_raises ArgumentError do
        parse_time(59.seconds)
      end

      assert_raises ArgumentError do
        parse_time(0.minutes)
      end
    end

    # For santity, do some tests on straight String
    should "parse correctly" do
      assert_equal '* * * * *', parse_time(1.minute)
      assert_equal '0,5,10,15,20,25,30,35,40,45,50,55 * * * *', parse_time(5.minutes)
      assert_equal '7,14,21,28,35,42,49,56 * * * *', parse_time(7.minutes)
      assert_equal '0,30 * * * *', parse_time(30.minutes)
      assert_equal '32 * * * *', parse_time(32.minutes)
      assert_not_equal '60 * * * *', parse_time(60.minutes) # 60 minutes bumps up into the hour range
    end

    # Test all minutes
    (2..59).each do |num|
      should "parse correctly for #{num} minutes" do
        start = 0
        start += num unless 60.modulo(num).zero?
        minutes = (start..59).step(num).to_a

        assert_equal "#{minutes.join(',')} * * * *", parse_time(num.minutes)
      end
    end
  end

  context "When parsing time in hours" do
    should "parse correctly" do
      assert_equal '0 * * * *', parse_time(1.hour)
      assert_equal '0 0,2,4,6,8,10,12,14,16,18,20,22 * * *', parse_time(2.hours)
      assert_equal '0 0,3,6,9,12,15,18,21 * * *', parse_time(3.hours)
      assert_equal '0 5,10,15,20 * * *', parse_time(5.hours)
      assert_equal '0 17 * * *', parse_time(17.hours)
      assert_not_equal '0 24 * * *', parse_time(24.hours) # 24 hours bumps up into the day range
    end

    (2..23).each do |num|
      should "parse correctly for #{num} hours" do
        start = 0
        start += num unless 24.modulo(num).zero?
        hours = (start..23).step(num).to_a

        assert_equal "0 #{hours.join(',')} * * *", parse_time(num.hours)
      end
    end

    should "parse correctly when given an 'at' with minutes as an Integer" do
      assert_minutes_equals "1",  1
      assert_minutes_equals "14", 14
      assert_minutes_equals "27", 27
      assert_minutes_equals "55", 55
    end

    should "parse correctly when given an 'at' with minutes as a Time" do
      # Basically just testing that Chronic parses some times and we get the minutes out of it
      assert_minutes_equals "1",  '3:01am'
      assert_minutes_equals "1",  'January 21 2:01 PM'
      assert_minutes_equals "0",  'midnight'
      assert_minutes_equals "59", '13:59'
    end
  end

  context "When parsing time in days (of month)" do
    should "parse correctly" do
      assert_equal '0 0 * * *', parse_time(1.days)
      assert_equal '0 0 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31 * *', parse_time(2.days)
      assert_equal '0 0 1,5,9,13,17,21,25,29 * *', parse_time(4.days)
      assert_equal '0 0 1,8,15,22 * *', parse_time(7.days)
      assert_equal '0 0 1,17 * *', parse_time(16.days)
      assert_equal '0 0 17 * *', parse_time(17.days)
      assert_equal '0 0 29 * *', parse_time(29.days)
      assert_not_equal '0 0 30 * *', parse_time(30.days) # 30 days bumps into the month range
    end

    should "parse correctly when given an 'at' with hours, minutes as a Time" do
      # first param is an array with [hours, minutes]
      assert_hours_and_minutes_equals %w(3 45),  '3:45am'
      assert_hours_and_minutes_equals %w(20 1),  '8:01pm'
      assert_hours_and_minutes_equals %w(0 0),   'midnight'
      assert_hours_and_minutes_equals %w(1 23),  '1:23 AM'
      assert_hours_and_minutes_equals %w(23 59), 'March 21 11:59 pM'
    end

    should "parse correctly when given an 'at' with hours as an Integer" do
      # first param is an array with [hours, minutes]
      assert_hours_and_minutes_equals %w(1 0),  1
      assert_hours_and_minutes_equals %w(3 0),  3
      assert_hours_and_minutes_equals %w(15 0), 15
      assert_hours_and_minutes_equals %w(19 0), 19
      assert_hours_and_minutes_equals %w(23 0), 23
    end
  end

  context "When parsing time in months" do
    should "parse correctly" do
      assert_equal '0 0 1 * *', parse_time(1.month)
      assert_equal '0 0 1 1,3,5,7,9,11 *', parse_time(2.months)
      assert_equal '0 0 1 1,4,7,10 *', parse_time(3.months)
      assert_equal '0 0 1 1,5,9 *', parse_time(4.months)
      assert_equal '0 0 1 1,6 *', parse_time(5.months)
      assert_equal '0 0 1 7 *', parse_time(7.months)
      assert_equal '0 0 1 8 *', parse_time(8.months)
      assert_equal '0 0 1 9 *', parse_time(9.months)
      assert_equal '0 0 1 10 *', parse_time(10.months)
      assert_equal '0 0 1 11 *', parse_time(11.months)
      assert_equal '0 0 1 12 *', parse_time(12.months)
    end

    should "parse correctly when given an 'at' with days, hours, minutes as a Time" do
      # first param is an array with [days, hours, minutes]
      assert_days_and_hours_and_minutes_equals %w(1 3 45),  'January 1st 3:45am'
      assert_days_and_hours_and_minutes_equals %w(11 23 0), 'Feb 11 11PM'
      assert_days_and_hours_and_minutes_equals %w(22 1 1), 'march 22nd at 1:01 am'
      assert_days_and_hours_and_minutes_equals %w(23 0 0), 'march 22nd at midnight' # looks like midnight means the next day
    end

    should "parse correctly when given an 'at' with days as an Integer" do
      # first param is an array with [days, hours, minutes]
      assert_days_and_hours_and_minutes_equals %w(1 0 0),  1
      assert_days_and_hours_and_minutes_equals %w(15 0 0), 15
      assert_days_and_hours_and_minutes_equals %w(29 0 0), 29
    end
  end

  context "When parsing time in days (of week)" do
    should "parse days of the week correctly" do
      {
        '0' => %w(sun Sunday SUNDAY SUN),
        '1' => %w(mon Monday MONDAY MON),
        '2' => %w(tue tues Tuesday TUESDAY TUE),
        '3' => %w(wed Wednesday WEDNESDAY WED),
        '4' => %w(thu thurs thur Thursday THURSDAY THU),
        '5' => %w(fri Friday FRIDAY FRI),
        '6' => %w(sat Saturday SATURDAY SAT)
      }.each do |day, day_tests|
        day_tests.each do |day_test|
          assert_equal "0 0 * * #{day}", parse_time(day_test)
        end
      end
    end

    should "allow additional directives" do
      assert_equal '30 13 * * 5', parse_time('friday', nil, "1:30 pm")
      assert_equal '22 2 * * 1', parse_time('Monday', nil, "2:22am")
      assert_equal '55 17 * * 4', parse_time('THU', nil, "5:55PM")
    end

    should "parse weekday correctly" do
      assert_equal '0 0 * * 1-5', parse_time('weekday')
      assert_equal '0 0 * * 1-5', parse_time('Weekdays')
      assert_equal '0 1 * * 1-5', parse_time('Weekdays', nil, "1:00 am")
      assert_equal '59 5 * * 1-5', parse_time('Weekdays', nil, "5:59 am")
    end

    should "parse weekend correctly" do
      assert_equal '0 0 * * 6,0', parse_time('weekend')
      assert_equal '0 0 * * 6,0', parse_time('Weekends')
      assert_equal '0 7 * * 6,0', parse_time('Weekends', nil, "7am")
      assert_equal '2 18 * * 6,0', parse_time('Weekends', nil, "6:02PM")
    end
  end
  
  context "When parsing time using the cron shortcuts" do
    should "parse a :symbol into the correct shortcut" do
      assert_equal '@reboot',   parse_time(:reboot)
      assert_equal '@annually', parse_time(:year)
      assert_equal '@annually', parse_time(:yearly)
      assert_equal '@daily',    parse_time(:day)
      assert_equal '@daily',    parse_time(:daily)
      assert_equal '@midnight', parse_time(:midnight)
      assert_equal '@monthly',  parse_time(:month)
      assert_equal '@monthly',  parse_time(:monthly)
      assert_equal '@hourly',   parse_time(:hour)
      assert_equal '@hourly',   parse_time(:hourly)
    end
    
    should "raise an exception if a valid shortcut is given but also an :at" do
      assert_raises ArgumentError do
        parse_time(:hour, nil, "1:00 am")
      end
      
      assert_raises ArgumentError do
        parse_time(:reboot, nil, 5)
      end
      
      assert_raises ArgumentError do
        parse_time(:day, nil, '4:20pm')
      end
    end
  end

private

  def assert_days_and_hours_and_minutes_equals(expected, time)
    cron = parse_time(2.months, 'some task', time)
    minutes, hours, days, *garbage = cron.split(' ')
    assert_equal expected, [days, hours, minutes]
  end

  def assert_hours_and_minutes_equals(expected, time)
    cron = parse_time(2.days, 'some task', time)
    minutes, hours, *garbage = cron.split(' ')
    assert_equal expected, [hours, minutes]
  end

  def assert_minutes_equals(expected, time)
    cron = parse_time(2.hours, 'some task', time)
    assert_equal expected, cron.split(' ')[0]
  end

  def parse_time(time = nil, task = nil, at = nil)
    Whenever::Output::Cron.new(time, task, at).time_in_cron_syntax
  end

end