require 'capistrano/version'

if defined?(Capistrano::VERSION) && Gem::Version.new(Capistrano::VERSION).release >= Gem::Version.new('3.0.0')
  load File.expand_path("../tasks/whenever.rake", __FILE__)
else
  require 'whenever/capistrano/v2/hooks'
end
