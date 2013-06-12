# Environment variable defaults to RAILS_ENV
set :environment_variable, "RAILS_ENV"
# Environment defaults to production
set :environment, "production"
# Path defaults to the directory `whenever` was run from
set :path, Whenever.path

# All jobs are wrapped in this template.
# http://blog.scoutapp.com/articles/2010/09/07/rvm-and-cron-in-production
set :job_template, "/bin/bash -l -c ':job'"

job_type :command, ":task :output"

# Run rake through bundler if possible
if Whenever.bundler?
  job_type :rake, "cd :path && :environment_variable=:environment bundle exec rake :task --silent :output"
  job_type :script, "cd :path && :environment_variable=:environment bundle exec script/:task :output"
else
  job_type :rake, "cd :path && :environment_variable=:environment rake :task --silent :output"
  job_type :script, "cd :path && :environment_variable=:environment script/:task :output"
end

# Create a runner job that's appropriate for the Rails version,
if Whenever.rails_binstub?
  set :runner_command, "bin/rails runner"
elsif Whenever.rails3?
  set :runner_command, "script/rails runner"
else
  set :runner_command, "script/runner"
end

job_type :runner, "cd :path && :runner_command -e :environment ':task' :output"
