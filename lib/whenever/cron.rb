require 'chronic'

module Whenever
  module Output
    class Cron
      DAYS = %w(sun mon tue wed thu fri sat)
      MONTHS = %w(jan feb mar apr may jun jul aug sep oct nov dec)
      KEYWORDS = [:reboot, :yearly, :annually, :monthly, :weekly, :daily, :midnight, :hourly]
      REGEX = /^(@(#{KEYWORDS.join '|'})|((\*?[\d\/,\-]*)\s){3}(\*?([\d\/,\-]|(#{MONTHS.join '|'}))*\s)(\*?([\d\/,\-]|(#{DAYS.join '|'}))*))$/i

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
        @at_given.is_a?(String) && (MONTHS.any? { |m| @at_given.downcase.index(m) } || @at_given[/\d\/\d/])
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
            timing[0] = comma_separated_timing(minute_frequency, 59, @at || 0)
          when Whenever.seconds(1, :hour)...Whenever.seconds(1, :day)
            hour_frequency = (@time / 60 / 60).round
            timing[0] = @at.is_a?(Time) ? @at.min : range_or_integer(@at, 0..59, 'Minute')
            timing[1] = comma_separated_timing(hour_frequency, 23)
          when Whenever.seconds(1, :day)...Whenever.seconds(1, :month)
            day_frequency = (@time / 24 / 60 / 60).round
            timing[0] = @at.is_a?(Time) ? @at.min  : 0
            timing[1] = @at.is_a?(Time) ? @at.hour : range_or_integer(@at, 0..23, 'Hour')
            timing[2] = comma_separated_timing(day_frequency, 31, 1)
          when Whenever.seconds(1, :month)...Whenever.seconds(1, :year)
            month_frequency = (@time / 30 / 24 / 60 / 60).round
            timing[0] = @at.is_a?(Time) ? @at.min  : 0
            timing[1] = @at.is_a?(Time) ? @at.hour : 0
            timing[2] = if @at.is_a?(Time)
              day_given? ? @at.day : 1
            else
              @at == 0 ? 1 : range_or_integer(@at, 1..31, 'Day')
            end
            timing[3] = comma_separated_timing(month_frequency, 12, 1)
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
              @at == 0 ? 1 : range_or_integer(@at, 1..12, 'Month')
            end
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

        DAYS.each_with_index do |day, i|
          return (timing << i) * " " if string.downcase.index(day)
        end

        raise ArgumentError, "Couldn't parse: #{@time.inspect}"
      end

      def range_or_integer(at, valid_range, name)
        must_be_between = "#{name} must be between #{valid_range.min}-#{valid_range.max}"
        if at.is_a?(Range)
          raise ArgumentError, "#{must_be_between}, #{at.min} given" unless valid_range.include?(at.min)
          raise ArgumentError, "#{must_be_between}, #{at.max} given" unless valid_range.include?(at.max)
          return "#{at.min}-#{at.max}"
        end
        raise ArgumentError, "#{must_be_between}, #{at} given" unless valid_range.include?(at)
        at
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
