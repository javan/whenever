Whenever is a Ruby gem that provides a clear syntax for writing and deploying cron jobs.

### Installation

```sh  
$ gem install whenever
```

Or with Bundler in your Gemfile.

```ruby
gem 'whenever', :require => false
```
 
### Getting started

```sh
$ cd /apps/my-great-project
$ wheneverize .
```

This will create an initial `config/schedule.rb` file for you.

### Example schedule.rb file

```ruby  
every 3.hours do
  runner "MyModel.some_process"       
  rake "my:rake:task"                 
  command "/usr/bin/my_great_command"
end

every 1.day, :at => '4:30 am' do 
  runner "MyModel.task_to_run_at_four_thirty_in_the_morning"
end

every :hour do # Many shortcuts available: :hour, :day, :month, :year, :reboot
  runner "SomeModel.ladeeda"
end

every :sunday, :at => '12pm' do # Use any day of the week or :weekend, :weekday 
  runner "Task.do_something_great"
end

every '0 0 27-31 * *' do
  command "echo 'you can use raw cron syntax too'"
end
```

### Define your own job types

Whenever ships with three pre-defined job types: command, runner, and rake. You can define your own with `job_type`.

For example:

```ruby
job_type :awesome, '/usr/local/bin/awesome :task :fun_level'

every 2.hours do
  awesome "party", :fun_level => "extreme"
end
```
  
Would run `/usr/local/bin/awesome party extreme` every two hours. `:task` is always replaced with the first argument, and any additional `:whatevers` are replaced with the options passed in or by variables that have been defined with `set`.

The default job types that ship with Whenever are defined like so:

```ruby
job_type :command, ":task :output"
job_type :rake,    "cd :path && RAILS_ENV=:environment bundle exec rake :task --silent :output"
job_type :runner,  "cd :path && script/rails runner -e :environment ':task' :output"
```

Pre-Rails 3 apps and apps that don't use Bundler will redefine the `rake` and `runner` jobs respectively to function correctly.

If a `:path` is not set it will default to the directory in which `whenever` was executed. `:environment` will default to 'production'. `:output` will be replaced with your output redirection settings which you can read more about here: <http://github.com/javan/whenever/wiki/Output-redirection-aka-logging-your-cron-jobs>

All jobs are by default run with `bash -l -c 'command...'`. Among other things, this allows your cron jobs to play nice with RVM by loading the entire environment instead of cron's somewhat limited environment. Read more: <http://blog.scoutapp.com/articles/2010/09/07/rvm-and-cron-in-production>

You can change this by setting your own `:job_template`.

```ruby
set :job_template, "bash -l -c ':job'"
```
  
Or set the job_template to nil to have your jobs execute normally.

```ruby
set :job_template, nil
```

### Capistrano integration

Use the built-in Capistrano recipe for easy crontab updates with deploys.

In your "config/deploy.rb" file:

```ruby
require "whenever/capistrano"
```

Take a look at the recipe for options you can set. <http://github.com/javan/whenever/blob/master/lib/whenever/capistrano.rb>
For example, if you're using bundler do this:

```ruby
set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"
```

If you are using different environments (such as staging, production), then you may want to do this:

```ruby
set :whenever_environment, defer { stage }
require "whenever/capistrano"
```

The capistrano variable `:stage` should be the one holding your environment name. This will make the correct `:environment` available in your `schedule.rb`.

If both your environments are on the same server you'll want to namespace them or they'll overwrite each other when you deploy:

```ruby
set :whenever_environment, defer { stage }
set :whenever_identifier, defer { "#{application}_#{stage}" }
require "whenever/capistrano"
```

### RVM Integration

If your production environment uses RVM (Ruby Version Manager) you will run into a gotcha that causes your cron jobs to hang.  This is not directly related to Whenever, and can be tricky to debug.  Your .rvmrc files must be trusted or else the cron jobs will hang waiting for the file to be trusted.  A solution is to disable the prompt by adding this line to your user rvm file in `~/.rvmrc`

`rvm_trust_rvmrcs_flag=1`

This tells rvm to trust all rvmrc files, which is documented here: http://wayneeseguin.beginrescueend.com/2010/08/22/ruby-environment-version-manager-rvm-1-0-0/

### The `whenever` command

```sh
$ cd /apps/my-great-project
$ whenever
```
  
This will simply show you your `schedule.rb` file converted to cron syntax. It does not read or write your crontab file. Run `whenever --help` for a complete list of options.

### Credit

Whenever was created for use at Inkling (<http://inklingmarkets.com>). Their take on it: <http://blog.inklingmarkets.com/2009/02/whenever-easy-way-to-do-cron-jobs-from.html>

Thanks to all the contributors who have made it even better: <http://github.com/javan/whenever/contributors>

### Discussion / Feedback / Issues / Bugs

For general discussion and questions, please use the google group: <http://groups.google.com/group/whenever-gem>

If you've found a genuine bug or issue, please use the Issues section on github: <http://github.com/javan/whenever/issues>

Ryan Bates created a great Railscast about Whenever: <http://railscasts.com/episodes/164-cron-in-ruby>
It's a little bit dated now, but remains a good introduction.

----

Compatible with Ruby 1.8.7-1.9.2, JRuby, and Rubinius. [![Build Status](https://secure.travis-ci.org/javan/whenever.png)](http://travis-ci.org/javan/whenever)

----

Copyright &copy; 2011 Javan Makhmali