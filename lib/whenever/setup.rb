# Environment variable defaults to RAILS_ENV
set :environment_variable, "RAILS_ENV"
# Environment defaults to the value of RAILS_ENV in the current environment if
# it's set or production otherwise
set :environment, ENV.fetch("RAILS_ENV", "production")
# Path defaults to the directory `whenever` was run from
set :path, Whenever.path

# Custom Chronic configuration for time parsing, empty by default
# Full list of options at: https://github.com/mojombo/chronic/blob/master/lib/chronic/parser.rb
set :chronic_options, {}

# All jobs are wrapped in this template.
# http://blog.scoutapp.com/articles/2010/09/07/rvm-and-cron-in-production
set :job_template, "/bin/bash -l -c ':job'"

set :runner_command, case
  when Whenever.bin_rails?
    "bin/rails runner"
  when Whenever.script_rails?
    "script/rails runner"
  else
    "script/runner"
  end

set :bundle_command, Whenever.bundler? ? "bundle exec" : ""
set :verbose_mode, options[:verbose] ? '' : "--silent"

job_type :command, ":task :output"
job_type :rake,    "cd :path && :environment_variable=:environment :bundle_command rake :task :verbose_mode :output"
job_type :script,  "cd :path && :environment_variable=:environment :bundle_command script/:task :output"
job_type :runner,  "cd :path && :bundle_command :runner_command -e :environment ':task' :output"
