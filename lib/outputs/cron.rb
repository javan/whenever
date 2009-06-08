module Whenever
  module Output

    class Cron

      attr_accessor :time, :task

      def initialize(time = nil, task = nil, at = nil)
        @time = time
        @task = task
        @at   = at.is_a?(String) ? (Chronic.parse(at) || 0) : (at || 0)
      end

      def self.enumerate(item)
        if item and item.is_a?(String)
          items = item.split(',')
        else
          items = item
          items = [items] unless items and items.respond_to?(:each)
        end
        items
      end

      def self.output(times, job)
        enumerate(times).each do |time|
          enumerate(job.at).each do |at|
            out = new(time, job.output, at)
            yield "#{out.time_in_cron_syntax} #{out.task}"
          end
        end
      end

      def time_in_cron_syntax
        case @time
          when Symbol then parse_symbol
          when String then parse_as_string
          else parse_time
        end
      end

    protected

      def parse_symbol
        shortcut = case @time
          when :reboot          then '@reboot'
          when :year, :yearly   then '@annually'
          when :day, :daily     then '@daily'
          when :midnight        then '@midnight'
          when :month, :monthly then '@monthly'
          when :week, :weekly   then '@weekly'
          when :hour, :hourly   then '@hourly'
        end
        
        if shortcut
          if @at > 0
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
          when 0.seconds...1.minute
            raise ArgumentError, "Time must be in minutes or higher"
          when 1.minute...1.hour
            minute_frequency = @time / 60
            timing[0] = comma_separated_timing(minute_frequency, 59)
          when 1.hour...1.day
            hour_frequency = (@time / 60 / 60).round
            timing[0] = @at.is_a?(Time) ? @at.min : @at
            timing[1] = comma_separated_timing(hour_frequency, 23)
          when 1.day...1.month
            day_frequency = (@time / 24 / 60 / 60).round
            timing[0] = @at.is_a?(Time) ? @at.min  : 0
            timing[1] = @at.is_a?(Time) ? @at.hour : @at
            timing[2] = comma_separated_timing(day_frequency, 31, 1)
          when 1.month..12.months
            month_frequency = (@time / 30  / 24 / 60 / 60).round
            timing[0] = @at.is_a?(Time) ? @at.min  : 0
            timing[1] = @at.is_a?(Time) ? @at.hour : 0
            timing[2] = @at.is_a?(Time) ? @at.day  : (@at.zero? ? 1 : @at)
            timing[3] = comma_separated_timing(month_frequency, 12, 1)
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
        return start     if frequency.blank? || frequency.zero?
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
