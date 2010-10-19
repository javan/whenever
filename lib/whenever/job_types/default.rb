job_type :command, ":task :output"
job_type :runner,  "cd :path && script/runner -e :environment ':task' :output"
job_type :rake,    "cd :path && RAILS_ENV=:environment rake :task --silent :output"
