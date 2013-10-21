if Gem::Version.new(Capistrano::VERSION).release >= Gem::Version.new('3.0.0')
  load File.expand_path("../tasks/whenever.rake", __FILE__)
else
  require_relative 'capistrano2'
end
