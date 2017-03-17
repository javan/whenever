# Environment variable defaults to RAILS_ENV
set :environment_variable, "RAILS_ENV"
# Environment defaults to production
set :environment, "production"
# Path defaults to the directory `whenever` was run from
set :path, Whenever.path

# Custom Chronic configuration for time parsing, empty by default
# Full list of options at: https://github.com/mojombo/chronic/blob/master/lib/chronic/parser.rb
set :chronic_options, {}

# All jobs are wrapped in this template.
# http://blog.scoutapp.com/articles/2010/09/07/rvm-and-cron-in-production

shell = "/bash"
ENV['PATH'].split(':').each do |folder| 
    if File.exists?(folder + shell) && File.executable?(folder + shell)
        shell = folder + shell
        break
    end
end

set :job_template, shell + " -l -c ':job'"

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
job_type :runner,  "cd :path && :bundle_command :runner_command -e :environment ':task' :output"
