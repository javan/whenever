set :environment, "production"
set :path, Whenever.path

# http://blog.scoutapp.com/articles/2010/09/07/rvm-and-cron-in-production
set :job_template, "/bin/bash -l -c ':job'"

job_type :command, ":task :output"
job_type :rake,    "cd :path && RAILS_ENV=:environment rake :task --silent :output"

# Create a runner job that's appropriate for the Rails version,
if File.exists?(File.join(Whenever.path, 'script', 'rails'))
  job_type :runner, "cd :path && script/rails runner -e :environment ':task' :output"
else
  job_type :runner, "cd :path && script/runner -e :environment ':task' :output"
end
