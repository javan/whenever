require 'test_helper'

class CronTest < Whenever::TestCase
  should "raise if less than 1 minute" do
    assert_raises ArgumentError do
      parse_time(Whenever.seconds(59, :seconds))
    end

    assert_raises ArgumentError do
      parse_time(Whenever.seconds(0, :minutes))
    end
  end

  # For sanity, do some tests on straight cron-syntax strings
  should "parse correctly" do
    assert_equal '* * * * *', parse_time(Whenever.seconds(1, :minute))
    assert_equal '0,5,10,15,20,25,30,35,40,45,50,55 * * * *', parse_time(Whenever.seconds(5, :minutes))
    assert_equal '7,14,21,28,35,42,49,56 * * * *', parse_time(Whenever.seconds(7, :minutes))
    assert_equal '0,30 * * * *', parse_time(Whenever.seconds(30, :minutes))
    assert_equal '32 * * * *', parse_time(Whenever.seconds(32, :minutes))
    assert '60 * * * *' != parse_time(Whenever.seconds(60, :minutes)) # 60 minutes bumps up into the hour range
  end

  # Test all minutes
  (2..59).each do |num|
    should "parse correctly for #{num} minutes" do
      start = 0
      start += num unless 60.modulo(num).zero?
      minutes = (start..59).step(num).to_a

      assert_equal "#{minutes.join(',')} * * * *", parse_time(Whenever.seconds(num, :minutes))
    end
  end
end

class CronParseHoursTest < Whenever::TestCase
  should "parse correctly" do
    assert_equal '0 * * * *', parse_time(Whenever.seconds(1, :hour))
    assert_equal '0 0,2,4,6,8,10,12,14,16,18,20,22 * * *', parse_time(Whenever.seconds(2, :hours))
    assert_equal '0 0,3,6,9,12,15,18,21 * * *', parse_time(Whenever.seconds(3, :hours))
    assert_equal '0 5,10,15,20 * * *', parse_time(Whenever.seconds(5, :hours))
    assert_equal '0 17 * * *', parse_time(Whenever.seconds(17, :hours))
    assert '0 24 * * *' != parse_time(Whenever.seconds(24, :hours)) # 24 hours bumps up into the day range
  end

  (2..23).each do |num|
    should "parse correctly for #{num} hours" do
      start = 0
      start += num unless 24.modulo(num).zero?
      hours = (start..23).step(num).to_a

      assert_equal "0 #{hours.join(',')} * * *", parse_time(Whenever.seconds(num, :hours))
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

  should "parse correctly when given an 'at' with minutes as a Time and custom Chronic options are set" do
    assert_minutes_equals "15", '3:15'
    assert_minutes_equals "15", '3:15', :chronic_options => { :hours24 => true }
    assert_minutes_equals "15", '3:15', :chronic_options => { :hours24 => false }

    assert_minutes_equals "30", '6:30'
    assert_minutes_equals "30", '6:30', :chronic_options => { :hours24 => true }
    assert_minutes_equals "30", '6:30', :chronic_options => { :hours24 => false }
  end

  should "parse correctly when given an 'at' with minutes as a Range" do
    assert_minutes_equals "15-30", 15..30
  end

  should "raise an exception when given an 'at' with an invalid minute value" do
    assert_raises ArgumentError do
      parse_time(Whenever.seconds(1, :hour), nil, 60)
    end

    assert_raises ArgumentError do
      parse_time(Whenever.seconds(1, :hour), nil, -1)
    end

    assert_raises ArgumentError do
      parse_time(Whenever.seconds(1, :hour), nil, 0..60)
    end

    assert_raises ArgumentError do
      parse_time(Whenever.seconds(1, :hour), nil, -1..59)
    end
  end
end

class CronParseDaysTest < Whenever::TestCase
  should "parse correctly" do
    assert_equal '0 0 * * *', parse_time(Whenever.seconds(1, :days))
    assert_equal '0 0 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31 * *', parse_time(Whenever.seconds(2, :days))
    assert_equal '0 0 1,5,9,13,17,21,25,29 * *', parse_time(Whenever.seconds(4, :days))
    assert_equal '0 0 1,8,15,22 * *', parse_time(Whenever.seconds(7, :days))
    assert_equal '0 0 1,17 * *', parse_time(Whenever.seconds(16, :days))
    assert_equal '0 0 17 * *', parse_time(Whenever.seconds(17, :days))
    assert_equal '0 0 29 * *', parse_time(Whenever.seconds(29, :days))
    assert '0 0 30 * *' != parse_time(Whenever.seconds(30, :days)) # 30 days bumps into the month range
  end

  should "parse correctly when given an 'at' with hours, minutes as a Time" do
    # first param is an array with [hours, minutes]
    assert_hours_and_minutes_equals %w(3 45),  '3:45am'
    assert_hours_and_minutes_equals %w(20 1),  '8:01pm'
    assert_hours_and_minutes_equals %w(0 0),   'midnight'
    assert_hours_and_minutes_equals %w(1 23),  '1:23 AM'
    assert_hours_and_minutes_equals %w(23 59), 'March 21 11:59 pM'
  end

  should "parse correctly when given an 'at' with hours, minutes as a Time and custom Chronic options are set" do
    # first param is an array with [hours, minutes]
    assert_hours_and_minutes_equals %w(15 15), '3:15'
    assert_hours_and_minutes_equals %w(3 15),  '3:15', :chronic_options => { :hours24 => true }
    assert_hours_and_minutes_equals %w(15 15), '3:15', :chronic_options => { :hours24 => false }

    assert_hours_and_minutes_equals %w(6 30),  '6:30'
    assert_hours_and_minutes_equals %w(6 30),  '6:30', :chronic_options => { :hours24 => true }
    assert_hours_and_minutes_equals %w(6 30),  '6:30', :chronic_options => { :hours24 => false }
  end

  should "parse correctly when given an 'at' with hours as an Integer" do
    # first param is an array with [hours, minutes]
    assert_hours_and_minutes_equals %w(1 0),  1
    assert_hours_and_minutes_equals %w(3 0),  3
    assert_hours_and_minutes_equals %w(15 0), 15
    assert_hours_and_minutes_equals %w(19 0), 19
    assert_hours_and_minutes_equals %w(23 0), 23
  end

  should "parse correctly when given an 'at' with hours as a Range" do
    assert_hours_and_minutes_equals %w(3-23 0), 3..23
  end

  should "raise an exception when given an 'at' with an invalid hour value" do
    assert_raises ArgumentError do
      parse_time(Whenever.seconds(1, :day), nil, 24)
    end

    assert_raises ArgumentError do
      parse_time(Whenever.seconds(1, :day), nil, -1)
    end

    assert_raises ArgumentError do
      parse_time(Whenever.seconds(1, :day), nil, 0..24)
    end

    assert_raises ArgumentError do
      parse_time(Whenever.seconds(1, :day), nil, -1..23)
    end
  end
end

class CronParseMonthsTest < Whenever::TestCase
  should "parse correctly" do
    assert_equal '0 0 1 * *', parse_time(Whenever.seconds(1, :month))
    assert_equal '0 0 1 1,3,5,7,9,11 *', parse_time(Whenever.seconds(2, :months))
    assert_equal '0 0 1 1,4,7,10 *', parse_time(Whenever.seconds(3, :months))
    assert_equal '0 0 1 1,5,9 *', parse_time(Whenever.seconds(4, :months))
    assert_equal '0 0 1 1,6 *', parse_time(Whenever.seconds(5, :months))
    assert_equal '0 0 1 7 *', parse_time(Whenever.seconds(7, :months))
    assert_equal '0 0 1 8 *', parse_time(Whenever.seconds(8, :months))
    assert_equal '0 0 1 9 *', parse_time(Whenever.seconds(9, :months))
    assert_equal '0 0 1 10 *', parse_time(Whenever.seconds(10, :months))
    assert_equal '0 0 1 11 *', parse_time(Whenever.seconds(11, :months))
    assert_equal '0 0 1 12 *', parse_time(Whenever.seconds(12, :months))
  end

  should "parse months with a date and/or time" do
    # should set the day to 1 if no date is given
    assert_equal '0 17 1 * *', parse_time(Whenever.seconds(1, :month), nil, "5pm")
    # should use the date if one is given
    assert_equal '0 2 23 * *', parse_time(Whenever.seconds(1, :month), nil, "February 23rd at 2am")
    # should use an iteger as the day
    assert_equal '0 0 5 * *', parse_time(Whenever.seconds(1, :month), nil, 5)
  end

  should "parse correctly when given an 'at' with days, hours, minutes as a Time" do
    # first param is an array with [days, hours, minutes]
    assert_days_and_hours_and_minutes_equals %w(1 3 45),  'January 1st 3:45am'
    assert_days_and_hours_and_minutes_equals %w(11 23 0), 'Feb 11 11PM'
    assert_days_and_hours_and_minutes_equals %w(22 1 1), 'march 22nd at 1:01 am'
    assert_days_and_hours_and_minutes_equals %w(23 0 0), 'march 22nd at midnight' # looks like midnight means the next day
  end

  should "parse correctly when given an 'at' with days, hours, minutes as a Time and custom Chronic options are set" do
    # first param is an array with [days, hours, minutes]
    assert_days_and_hours_and_minutes_equals %w(22 15 45), 'February 22nd 3:45'
    assert_days_and_hours_and_minutes_equals %w(22 15 45), '02/22 3:45'
    assert_days_and_hours_and_minutes_equals %w(22 3 45),  'February 22nd 3:45', :chronic_options => { :hours24 => true }
    assert_days_and_hours_and_minutes_equals %w(22 15 45), 'February 22nd 3:45', :chronic_options => { :hours24 => false }

    assert_days_and_hours_and_minutes_equals %w(3 8 15), '02/03 8:15'
    assert_days_and_hours_and_minutes_equals %w(3 8 15), '02/03 8:15', :chronic_options => { :endian_precedence => :middle }
    assert_days_and_hours_and_minutes_equals %w(2 8 15), '02/03 8:15', :chronic_options => { :endian_precedence => :little }

    assert_days_and_hours_and_minutes_equals %w(4 4 50),  '03/04 4:50', :chronic_options => { :endian_precedence => :middle, :hours24 => true }
    assert_days_and_hours_and_minutes_equals %w(4 16 50), '03/04 4:50', :chronic_options => { :endian_precedence => :middle, :hours24 => false }
    assert_days_and_hours_and_minutes_equals %w(3 4 50),  '03/04 4:50', :chronic_options => { :endian_precedence => :little, :hours24 => true }
    assert_days_and_hours_and_minutes_equals %w(3 16 50), '03/04 4:50', :chronic_options => { :endian_precedence => :little, :hours24 => false }
  end

  should "parse correctly when given an 'at' with days as an Integer" do
    # first param is an array with [days, hours, minutes]
    assert_days_and_hours_and_minutes_equals %w(1 0 0),  1
    assert_days_and_hours_and_minutes_equals %w(15 0 0), 15
    assert_days_and_hours_and_minutes_equals %w(29 0 0), 29
  end

  should "parse correctly when given an 'at' with days as a Range" do
    assert_days_and_hours_and_minutes_equals %w(1-7 0 0), 1..7
  end

  should "raise an exception when given an 'at' with an invalid day value" do
    assert_raises ArgumentError do
      parse_time(Whenever.seconds(1, :month), nil, 32)
    end

    assert_raises ArgumentError do
      parse_time(Whenever.seconds(1, :month), nil, -1)
    end

    assert_raises ArgumentError do
      parse_time(Whenever.seconds(1, :month), nil, 0..30)
    end

    assert_raises ArgumentError do
      parse_time(Whenever.seconds(1, :month), nil, 1..32)
    end
  end
end

class CronParseYearTest < Whenever::TestCase
  should "parse correctly" do
    assert_equal '0 0 1 1 *', parse_time(Whenever.seconds(1, :year))
  end

  should "parse year with a date and/or time" do
    # should set the day and month to 1 if no date is given
    assert_equal '0 17 1 1 *', parse_time(Whenever.seconds(1, :year), nil, "5pm")
    # should use the date if one is given
    assert_equal '0 2 23 2 *', parse_time(Whenever.seconds(1, :year), nil, "February 23rd at 2am")
    # should use an iteger as the month
    assert_equal '0 0 1 5 *', parse_time(Whenever.seconds(1, :year), nil, 5)
  end

  should "parse correctly when given an 'at' with days, hours, minutes as a Time" do
    # first param is an array with [months, days, hours, minutes]
    assert_months_and_days_and_hours_and_minutes_equals %w(1 1 3 45),  'January 1st 3:45am'
    assert_months_and_days_and_hours_and_minutes_equals %w(2 11 23 0), 'Feb 11 11PM'
    assert_months_and_days_and_hours_and_minutes_equals %w(3 22 1 1),  'march 22nd at 1:01 am'
    assert_months_and_days_and_hours_and_minutes_equals %w(3 23 0 0),  'march 22nd at midnight' # looks like midnight means the next day
  end

  should "parse correctly when given an 'at' with days, hours, minutes as a Time and custom Chronic options are set" do
    # first param is an array with [months, days, hours, minutes]
    assert_months_and_days_and_hours_and_minutes_equals %w(2 22 15 45), 'February 22nd 3:45'
    assert_months_and_days_and_hours_and_minutes_equals %w(2 22 15 45), '02/22 3:45'
    assert_months_and_days_and_hours_and_minutes_equals %w(2 22 3 45),  'February 22nd 3:45', :chronic_options => { :hours24 => true }
    assert_months_and_days_and_hours_and_minutes_equals %w(2 22 15 45), 'February 22nd 3:45', :chronic_options => { :hours24 => false }

    assert_months_and_days_and_hours_and_minutes_equals %w(2 3 8 15), '02/03 8:15'
    assert_months_and_days_and_hours_and_minutes_equals %w(2 3 8 15), '02/03 8:15', :chronic_options => { :endian_precedence => :middle }
    assert_months_and_days_and_hours_and_minutes_equals %w(3 2 8 15), '02/03 8:15', :chronic_options => { :endian_precedence => :little }

    assert_months_and_days_and_hours_and_minutes_equals %w(3 4 4 50),  '03/04 4:50', :chronic_options => { :endian_precedence => :middle, :hours24 => true }
    assert_months_and_days_and_hours_and_minutes_equals %w(3 4 16 50), '03/04 4:50', :chronic_options => { :endian_precedence => :middle, :hours24 => false }
    assert_months_and_days_and_hours_and_minutes_equals %w(4 3 4 50),  '03/04 4:50', :chronic_options => { :endian_precedence => :little, :hours24 => true }
    assert_months_and_days_and_hours_and_minutes_equals %w(4 3 16 50), '03/04 4:50', :chronic_options => { :endian_precedence => :little, :hours24 => false }
  end

  should "parse correctly when given an 'at' with month as an Integer" do
    # first param is an array with [months, days, hours, minutes]
    assert_months_and_days_and_hours_and_minutes_equals %w(1 1 0 0),  1
    assert_months_and_days_and_hours_and_minutes_equals %w(5 1 0 0),  5
    assert_months_and_days_and_hours_and_minutes_equals %w(12 1 0 0), 12
  end

  should "parse correctly when given an 'at' with month as a Range" do
    assert_months_and_days_and_hours_and_minutes_equals %w(1-3 1 0 0), 1..3
  end

  should "raise an exception when given an 'at' with an invalid month value" do
    assert_raises ArgumentError do
      parse_time(Whenever.seconds(1, :year), nil, 13)
    end

    assert_raises ArgumentError do
      parse_time(Whenever.seconds(1, :year), nil, -1)
    end

    assert_raises ArgumentError do
      parse_time(Whenever.seconds(1, :year), nil, 0..12)
    end

    assert_raises ArgumentError do
      parse_time(Whenever.seconds(1, :year), nil, 1..13)
    end
  end
end

class CronParseDaysOfWeekTest < Whenever::TestCase
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

class CronParseShortcutsTest < Whenever::TestCase
  should "parse a :symbol into the correct shortcut" do
    assert_equal '@reboot',   parse_time(:reboot)
    assert_equal '@annually', parse_time(:annually)
    assert_equal '@yearly',   parse_time(:yearly)
    assert_equal '@daily',    parse_time(:daily)
    assert_equal '@midnight', parse_time(:midnight)
    assert_equal '@monthly',  parse_time(:monthly)
    assert_equal '@weekly',   parse_time(:weekly)
    assert_equal '@hourly',   parse_time(:hourly)
  end

  should "convert time-based shortcuts to times" do
    assert_equal '0 0 1 * *', parse_time(:month)
    assert_equal '0 0 * * *', parse_time(:day)
    assert_equal '0 * * * *', parse_time(:hour)
    assert_equal '0 0 1 1 *', parse_time(:year)
    assert_equal '0 0 1,8,15,22 * *', parse_time(:week)
  end

  should "raise an exception if a valid shortcut is given but also an :at" do
    assert_raises ArgumentError do
      parse_time(:hourly, nil, "1:00 am")
    end

    assert_raises ArgumentError do
      parse_time(:reboot, nil, 5)
    end

    assert_raises ArgumentError do
      parse_time(:daily, nil, '4:20pm')
    end
  end
end

class CronParseRubyTimeTest < Whenever::TestCase
  should "process things like `1.day` correctly" do
    assert_equal "0 0 * * *", parse_time(1.day)
  end
end

class CronParseRawTest < Whenever::TestCase
  should "raise if cron-syntax string is too long" do
    assert_raises ArgumentError do
      parse_time('* * * * * *')
    end
  end

  should "raise if cron-syntax string is invalid" do
    assert_raises ArgumentError do
      parse_time('** * * * *')
    end
  end

  should "return the same cron sytax" do
    crons = ['0 0 27-31 * *', '* * * * *', '2/3 1,9,22 11-26 1-6 *', '*/5 6-23 * * *',
             "*\t*\t*\t*\t*",
             '7 17 * * FRI', '7 17 * * Mon-Fri', '30 12 * Jun *', '30 12 * Jun-Aug *',
             '@reboot', '@yearly', '@annually', '@monthly', '@weekly',
             '@daily', '@midnight', '@hourly']
    crons.each do |cron|
      assert_equal cron, parse_time(cron)
    end
  end
end
