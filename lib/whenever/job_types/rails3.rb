# Determine if this is a Rails 3 app by looking for a script/rails file.
# If it is, preserve the Rails 2 runner job as rails2_runner and then
# define a new job for Rails 3 as the default runner.

if File.exists?(File.join(Whenever.path, 'script', 'rails'))
  class_eval { alias_method :rails2_runner, :runner }
  job_type :runner,  "cd :path && script/rails runner -e :environment ':task'"
end