require 'rubygems'

# Want to test the files here, in lib, not in an installed version of the gem.
$:.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'whenever'

require 'shoulda'
require 'mocha'

module TestExtensions
  
  def two_hours
    "0 0,2,4,6,8,10,12,14,16,18,20,22 * * *"
  end
  
end

class Test::Unit::TestCase
  include TestExtensions
end

def set_default_work_week
  # Reset weekdays and weekend to default values.
  Whenever::Output::Cron.weekdays, Whenever::Output::Cron.weekend = '1-5', '6,0'
end
