module Whenever
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 2
    TINY  = 2

    STRING = [MAJOR, MINOR, TINY].join('.')
  end
end unless defined?(Whenever::VERSION)