require 'rubygems'
require 'test/unit'

require File.expand_path(File.dirname(__FILE__) + "/../lib/whenever")

begin
  require 'shoulda'
rescue LoadError
  warn 'To test Whenever you need the shoulda gem:'
  warn '$ sudo gem install thoughtbot-shoulda'
  exit(1)
end

begin
  require 'mocha'
rescue LoadError
  warn 'To test Whenever you need the mocha gem:'
  warn '$ sudo gem install mocha'
  exit(1)
end


module TestExtensions
  
  def two_hours
    "0 0,2,4,6,8,10,12,14,16,18,20,22 * * *"
  end
  
end

class Test::Unit::TestCase
  include TestExtensions
end
