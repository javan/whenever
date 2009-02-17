module Whenever
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 1
    TINY  = 3

    STRING = [MAJOR, MINOR, TINY].join('.')
  end
end unless defined?(Whenever::VERSION)