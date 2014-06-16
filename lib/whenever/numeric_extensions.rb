# These are a minimal version of the active support Numeric extensions, for
# environments where activesupport isn't available.
#
# They don't have all the features of the activesupport extensions (for example:
# the returned values are just Fixnums, so you can't do things like 1.week.from_now),
# but they do cover the use cases needed for describing cron schedules.
#
class Numeric
  # Return the number of seconds represented by the current number
  def seconds
    self.to_i
  end
  alias :second :seconds

  # Return the number of minutes represented by the current number
  def minutes
    self.to_i * 60
  end
  alias :minute :minutes

  # Return the number of hours represented by the current number
  def hours
    self.to_i * 3_600
  end
  alias :hour :hours

  # Return the number of days represented by the current number
  def days
    self.to_i * 86_400
  end
  alias :day :days

  # Return the number of weeks represented by the current number
  def weeks
    self.to_i * 604_800
  end
  alias :week :weeks

  # Return the number of months represented by the current number
  def months
    self.to_i * 2_592_000
  end
  alias :month :months

  # Return the number of years represented by the current number
  def years
    self.to_i * 31_557_600
  end
  alias :year :years

end
