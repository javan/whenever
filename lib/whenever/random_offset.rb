module Whenever
  class RandomOffset
    RANDOM_MAX = 32767 # max value for bash $Random. 15 bits of entropy ought to be plenty for this purpose

    # Bash random number generator. Given 5, will return a random number from 0 to 10, with uniform probability.
    # For ranges exceeding 2^15 seconds (9 hours), we use multiplication to get the random number into the right range.
    # This is not great randomness, but it still gives 2^15 possible results so it should be fine for the intended purpose.
    def self.sleep_expression(center)
      maximum = center * 2 + 1
      multiplier = maximum.fdiv(RANDOM_MAX).ceil
      if multiplier > 1
        "sleep $(expr ($RANDOM * #{multiplier}) % #{maximum})"
      else
        "sleep $(expr $RANDOM % #{maximum})"
      end
    end

  end
end
