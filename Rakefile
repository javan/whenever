require 'rubygems'
require 'rake'
require 'echoe'
require 'lib/base'

Echoe.new('whenever', Whenever::VERSION) do |p|
  p.description    = "Provides (clean) ruby syntax for defining (messy) cron jobs and running them Whenever."
  p.url            = "http://github.com/javan/whenever"
  p.author         = "Javan Makhmali"
  p.email          = "javan@javan.us"
  p.dependencies   = ["chronic", "activesupport"]
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.development_dependencies = []
end