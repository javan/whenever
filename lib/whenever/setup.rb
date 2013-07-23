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

# Create a runner job that's appropriate for the Rails version
def runner_for_app
  case
  when Whenever.bin_rails?
    "bin/rails runner"
  when Whenever.script_rails?
    "script/rails runner"
  else
    "script/runner"
  end
end

job_type :runner, "cd :path && #{runner_for_app} -e :environment ':task' :output"
