require './lib/version'

require 'rubygems'
require 'rake'
require 'echoe'

WHENEVER_VERSION = Whenever::VERSION::STRING.dup

Echoe.new('whenever', WHENEVER_VERSION) do |p|
  p.changelog      = "CHANGELOG.rdoc"
  p.description    = "Provides clean ruby syntax for defining messy cron jobs and running them Whenever."
  p.url            = "http://github.com/javan/whenever"
  p.author         = "Javan Makhmali"
  p.email          = "javan@javan.us"
  p.dependencies   = ["chronic", "activesupport"]
end