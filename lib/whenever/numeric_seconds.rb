module Whenever
  class NumericSeconds
    attr_reader :number

    def self.seconds(number, units)
      new(number).send(units)
    end

    def initialize(number)
      @number = number.to_i
    end

    def seconds
      number
    end
    alias :second :seconds

    def minutes
      number * 60
    end
    alias :minute :minutes

    def hours
      number * 3_600
    end
    alias :hour :hours

    def days
      number * 86_400
    end
    alias :day :days

    def weeks
      number * 604_800
    end
    alias :week :weeks

    def months
      number * 2_592_000
    end
    alias :month :months

    def years
      number * 31_557_600
    end
    alias :year :years
  end
end
