# Environment variable defaults to RAILS_ENV
set :environment_variable, "RAILS_ENV"
# Environment defaults to production
set :environment, "production"
# Path defaults to the directory `whenever` was run from
set :path, Whenever.path

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

job_type :command, ":task :output"
job_type :rake,    "cd :path && :environment_variable=:environment :bundle_command rake :task --silent :output"
job_type :script,  "cd :path && :environment_variable=:environment :bundle_command script/:task :output"
job_type :runner,  "cd :path && :runner_command -e :environment ':task' :output"
