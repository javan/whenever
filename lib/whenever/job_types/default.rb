job_type :command, ":task :output"
job_type :rake,    "cd :path && RAILS_ENV=:environment rake :task --silent :output"

if File.exists?(File.join(Whenever.path, 'script', 'rails'))
  job_type :runner, "cd :path && script/rails runner -e :environment ':task' :output"
else
  job_type :runner, "cd :path && script/runner -e :environment ':task' :output"
end
