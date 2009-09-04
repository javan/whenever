module Whenever
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 3
    TINY  = 7

    STRING = [MAJOR, MINOR, TINY].join('.')
  end
end unless defined?(Whenever::VERSION)