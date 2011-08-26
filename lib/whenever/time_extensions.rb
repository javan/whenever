# A reimplementation of ActiveSupport's time extensions on numeric types.
# It is not quite equivalent to the code in ActiveSupport.
# ActiveSupport methods return Duration objects, not numbers.
# Whenever does not use any of additional functionality provided by
# Duration objects, therefore these methods return numbers.
module Whenever
  module TimeExtensions
    def seconds
      self
    end
    alias :second :seconds
    
    def minutes
      self * 60
    end
    alias :minute :minutes
    
    def hours
      self * 3600
    end
    alias :hour :hours
    
    def days
      self * 86400
    end
    alias :day :days
    
    def weeks
      self * 7 * 86400
    end
    alias :week :weeks
    
    def fortnights
      self * 14 * 86400
    end
    alias :fortnight :fortnights
    
    def months
      self * 30 * 86400
    end
    alias :month :months
  end
end

class Numeric
  include Whenever::TimeExtensions
end
