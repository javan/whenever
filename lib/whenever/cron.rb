require 'chronic'

module Whenever
  module Output
    class Cron
      KEYWORDS = [:reboot, :yearly, :annually, :monthly, :weekly, :daily, :midnight, :hourly]
      REGEX = /^(@(#{KEYWORDS.join '|'})|((\*?[\d\/,\-]*)\s*){5})$/

      attr_accessor :time, :task

      def initialize(time = nil, task = nil, at = nil, options = {})
        chronic_options = options[:chronic_options] || {}

        @at_given = at
        @time = time
        @task = task
        @at   = at.is_a?(String) ? (Chronic.parse(at, chronic_options) || 0) : (at || 0)
      end

      def self.enumerate(item, detect_cron = true)
        if item and item.is_a?(String)
          items =
            if detect_cron && item =~ REGEX
              [item]
            else
              item.split(',')
            end
        else
          items = item
          items = [items] unless items and items.respond_to?(:each)
        end
        items
      end

      def self.output(times, job, options = {})
        enumerate(times).each do |time|
          enumerate(job.at, false).each do |at|
            yield new(time, job.output, at, options).output
          end
        end
      end

      def output
        [time_in_cron_syntax, task].compact.join(' ').strip
      end

      def time_in_cron_syntax
        @time = @time.to_i if @time.is_a?(Numeric) # Compatibility with `1.day` format using ruby 2.3 and activesupport
        case @time
          when REGEX  then @time # raw cron syntax given
          when Symbol then parse_symbol
          when String then parse_as_string
          else parse_time
        end
      end

    protected
      def day_given?
        months = %w(jan feb mar apr may jun jul aug sep oct nov dec)
        @at_given.is_a?(String) && (months.any? { |m| @at_given.downcase.index(m) } || @at_given[/\d\/\d/])
      end

      def parse_symbol
        shortcut = case @time
          when *KEYWORDS then "@#{@time}" # :reboot => '@reboot'
          when :year     then Whenever.seconds(1, :year)
          when :day      then Whenever.seconds(1, :day)
          when :month    then Whenever.seconds(1, :month)
          when :week     then Whenever.seconds(1, :week)
          when :hour     then Whenever.seconds(1, :hour)
          when :minute   then Whenever.seconds(1, :minute)
        end

        if shortcut.is_a?(Numeric)
          @time = shortcut
          parse_time
        elsif shortcut
          if @at.is_a?(Time) || (@at.is_a?(Numeric) && @at > 0)
            raise ArgumentError, "You cannot specify an ':at' when using the shortcuts for times."
          else
            return shortcut
          end
        else
          parse_as_string
        end
      end

      def parse_time
        timing = Array.new(5, '*')
        case @time
          when Whenever.seconds(0, :seconds)...Whenever.seconds(1, :minute)
            raise ArgumentError, "Time must be in minutes or higher"
          when Whenever.seconds(1, :minute)...Whenever.seconds(1, :hour)
            minute_frequency = @time / 60
            starting_minute = @at.is_a?(Time) ? @at.min : @at
            timing[0] = comma_separated_timing(minute_frequency, 59, starting_minute || 0)
          when Whenever.seconds(1, :hour)...Whenever.seconds(1, :day)
            hour_frequency = (@time / 60 / 60).round
            timing[0] = @at.is_a?(Time) ? @at.min : @at
            timing[1] = comma_separated_timing(hour_frequency, 23)
            raise ArgumentError, "Minute must be between 0-59, #{timing[0]} given" unless (0..59).include?(timing[0])
          when Whenever.seconds(1, :day)...Whenever.seconds(1, :month)
            day_frequency = (@time / 24 / 60 / 60).round
            timing[0] = @at.is_a?(Time) ? @at.min  : 0
            timing[1] = @at.is_a?(Time) ? @at.hour : @at
            timing[2] = comma_separated_timing(day_frequency, 31, 1)
            raise ArgumentError, "Hour must be between 0-23, #{timing[1]} given" unless (0..23).include?(timing[1])
          when Whenever.seconds(1, :month)...Whenever.seconds(1, :year)
            month_frequency = (@time / 30 / 24 / 60 / 60).round
            timing[0] = @at.is_a?(Time) ? @at.min  : 0
            timing[1] = @at.is_a?(Time) ? @at.hour : 0
            timing[2] = if @at.is_a?(Time)
              day_given? ? @at.day : 1
            else
              @at.zero? ? 1 : @at
            end
            timing[3] = comma_separated_timing(month_frequency, 12, 1)
            raise ArgumentError, "Day must be between 1-31, #{timing[2]} given" unless (1..31).include?(timing[2])
          when Whenever.seconds(1, :year)
            timing[0] = @at.is_a?(Time) ? @at.min  : 0
            timing[1] = @at.is_a?(Time) ? @at.hour : 0
            timing[2] = if @at.is_a?(Time)
              day_given? ? @at.day : 1
            else
              1
            end
            timing[3] = if @at.is_a?(Time)
              day_given? ? @at.month : 1
            else
              @at.zero? ? 1 : @at
            end
            raise ArgumentError, "Month must be between 1-12, #{timing[3]} given" unless (1..12).include?(timing[3])
          else
            return parse_as_string
        end
        timing.join(' ')
      end

      def parse_as_string
        return unless @time
        string = @time.to_s

        timing = Array.new(4, '*')
        timing[0] = @at.is_a?(Time) ? @at.min  : 0
        timing[1] = @at.is_a?(Time) ? @at.hour : 0

        return (timing << '1-5') * " " if string.downcase.index('weekday')
        return (timing << '6,0') * " " if string.downcase.index('weekend')

        %w(sun mon tue wed thu fri sat).each_with_index do |day, i|
          return (timing << i) * " " if string.downcase.index(day)
        end

        raise ArgumentError, "Couldn't parse: #{@time}"
      end

      def comma_separated_timing(frequency, max, start = 0)
        return start     if frequency.nil? || frequency == "" || frequency.zero?
        return '*'       if frequency == 1
        return frequency if frequency > (max * 0.5).ceil

        original_start = start

        start += frequency unless (max + 1).modulo(frequency).zero? || start > 0
        output = (start..max).step(frequency).to_a

        max_occurances = (max.to_f  / (frequency.to_f)).round
        max_occurances += 1 if original_start.zero?

        output[0, max_occurances].join(',')
      end
    end
  end
end
