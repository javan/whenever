Whenever is a Ruby gem that provides a clear syntax for writing and deploying cron jobs.

### Installation

```sh
$ gem install whenever
```

Or with Bundler in your Gemfile.

```ruby
gem 'whenever', require: false
```

### Getting started

```sh
$ cd /apps/my-great-project
$ wheneverize .
```

This will create an initial `config/schedule.rb` file for you (as long as the config folder is already present in your project).

### The `whenever` command

```sh
$ cd /apps/my-great-project
$ whenever
```

This will simply show you your `schedule.rb` file converted to cron syntax. It does not read or write your crontab file; you'll need to do this in order for your jobs to execute:

```sh
$ whenever --update-crontab
```

Other commonly used options include:
```sh
$ whenever --user app # set a user as which to install the crontab
$ whenever --load-file config/my_schedule.rb # set the schedule file
$ whenever --crontab-command 'sudo crontab' # override the crontab command
```

You can list installed cron jobs using `crontab -l`.

Run `whenever --help` for a complete list of options for selecting the schedule to use, setting variables in the schedule, etc.

### Example schedule.rb file

```ruby
every 3.hours do # 1.minute 1.day 1.week 1.month 1.year is also supported
  runner "MyModel.some_process"
  rake "my:rake:task"
  command "/usr/bin/my_great_command"
end

every 1.day, at: '4:30 am' do
  runner "MyModel.task_to_run_at_four_thirty_in_the_morning"
end

every 1.day, at: ['4:30 am', '6:00 pm'] do
  runner "Mymodel.task_to_run_in_two_times_every_day"
end

every :hour do # Many shortcuts available: :hour, :day, :month, :year, :reboot
  runner "SomeModel.ladeeda"
end

every :sunday, at: '12pm' do # Use any day of the week or :weekend, :weekday
  runner "Task.do_something_great"
end

every '0 0 27-31 * *' do
  command "echo 'you can use raw cron syntax too'"
end

# run this task only on servers with the :app role in Capistrano
# see Capistrano roles section below
every :day, at: '12:20am', roles: [:app] do
  rake "app_server:task"
end
```

### Define your own job types

Whenever ships with three pre-defined job types: command, runner, and rake. You can define your own with `job_type`.

For example:

```ruby
job_type :awesome, '/usr/local/bin/awesome :task :fun_level'

every 2.hours do
  awesome "party", fun_level: "extreme"
end
```

Would run `/usr/local/bin/awesome party extreme` every two hours. `:task` is always replaced with the first argument, and any additional `:whatevers` are replaced with the options passed in or by variables that have been defined with `set`.

The default job types that ship with Whenever are defined like so:

```ruby
job_type :command, ":task :output"
job_type :rake,    "cd :path && :environment_variable=:environment bundle exec rake :task --silent :output"
job_type :runner,  "cd :path && bin/rails runner -e :environment ':task' :output"
job_type :script,  "cd :path && :environment_variable=:environment bundle exec script/:task :output"
```

Pre-Rails 3 apps and apps that don't use Bundler will redefine the `rake` and `runner` jobs respectively to function correctly.

If a `:path` is not set it will default to the directory in which `whenever` was executed. `:environment_variable` will default to 'RAILS_ENV'. `:environment` will default to 'production'. `:output` will be replaced with your output redirection settings which you can read more about here: <http://github.com/javan/whenever/wiki/Output-redirection-aka-logging-your-cron-jobs>

All jobs are by default run with `bash -l -c 'command...'`. Among other things, this allows your cron jobs to play nice with RVM by loading the entire environment instead of cron's somewhat limited environment. Read more: <http://blog.scoutapp.com/articles/2010/09/07/rvm-and-cron-in-production>

You can change this by setting your own `:job_template`.

```ruby
set :job_template, "bash -l -c ':job'"
```

Or set the job_template to nil to have your jobs execute normally.

```ruby
set :job_template, nil
```

### Parsing dates and times

Whenever uses the [Chronic](https://github.com/mojombo/chronic) gem to parse the specified dates and times.

You can set your custom Chronic configuration if the defaults don't fit you.

For example, to assume a 24 hour clock instead of the default 12 hour clock:

```ruby
set :chronic_options, hours24: true

# By default this would run the job every day at 3am
every 1.day, at: '3:00' do
  runner "MyModel.nightly_archive_job"
end
```

You can see a list of all available options here: <https://github.com/mojombo/chronic/blob/master/lib/chronic/parser.rb>

### Customize email recipient with the `MAILTO` environment variable

Output from the jobs is sent to the email address configured in the `MAILTO` environment variable.

There are many ways to further configure the recipient.

Example: A global configuration, overriding the environment's value:

```ruby
env 'MAILTO', 'output_of_cron@example.com'

every 3.hours do
  command "/usr/bin/my_great_command"
end
```

Example: A `MAILTO` configured for all the jobs in an interval block:

```ruby
every 3.hours, mailto: 'my_super_command@example.com'  do
  command "/usr/bin/my_super_command"
end
```

Example: A `MAILTO` configured for a single job:

```ruby
every 3.hours do
  command "/usr/bin/my_super_command", mailto: 'my_super_command_output@example.com'
end
```

### Capistrano integration

Use the built-in Capistrano recipe for easy crontab updates with deploys. For Capistrano V3, see the next section.

In your "config/deploy.rb" file:

```ruby
require "whenever/capistrano"
```

Take a look at the recipe for options you can set. <https://github.com/javan/whenever/blob/master/lib/whenever/capistrano/v2/recipes.rb>
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

If both your environments are on the same server you'll want to namespace them, or they'll overwrite each other when you deploy:

```ruby
set :whenever_environment, defer { stage }
set :whenever_identifier, defer { "#{application}_#{stage}" }
require "whenever/capistrano"
```

If you use a schedule at an alternative path, you may configure it like so:

```ruby
set :whenever_load_file, defer { "#{release_path}/somewhere/else/schedule.rb" }
require "whenever/capistrano"
```

### Capistrano V3 Integration

In your "Capfile" file:

```ruby
require "whenever/capistrano"
```

Take a look at the [load:defaults task](https://github.com/javan/whenever/blob/master/lib/whenever/capistrano/v3/tasks/whenever.rake) (bottom of file) for options you can set. For example, to namespace the crontab entries by application and stage do this in your "config/deploy.rb" file:

```ruby
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
```

The Capistrano integration by default expects the `:application` variable to be set in order to scope jobs in the crontab.

### Capistrano roles

The first thing to know about the new roles support is that it is entirely
optional and backwards-compatible. If you don't need different jobs running on
different servers in your capistrano deployment, then you can safely stop reading
now and everything should just work the same way it always has.

When you define a job in your schedule.rb file, by default it will be deployed to
all servers in the whenever_roles list (which defaults to `[:db]`).

However, if you want to restrict certain jobs to only run on subset of servers,
you can add a `roles: [...]` argument to their definitions. **Make sure to add
that role to the whenever_roles list in your deploy.rb.**

When you run `cap deploy`, jobs with a :roles list specified will only be added to
the crontabs on servers with one or more of the roles in that list.

Jobs with no :roles argument will be deployed to all servers in the whenever_roles
list. This is to maintain backward compatibility with previous releases of whenever.

So, for example, with the default whenever_roles of `[:db]`, a job like this would be
deployed to all servers with the `:db` role:

```ruby
every :day, at: '12:20am' do
  rake 'foo:bar'
end
```

If we set whenever_roles to `[:db, :app]` in deploy.rb, and have the following
jobs in schedule.rb:

```ruby
every :day, at: '1:37pm', roles: [:app] do
  rake 'app:task' # will only be added to crontabs of :app servers
end

every :hour, roles: [:db] do
  rake 'db:task' # will only be added to crontabs of :db servers
end

every :day, at: '12:02am' do
  command "run_this_everywhere" # will be deployed to :db and :app servers
end
```

Here are the basic rules:

  1. If a server's role isn't listed in whenever_roles, it will *never* have jobs
     added to its crontab.
  1. If a server's role is listed in the whenever_roles, then it will have all
     jobs added to its crontab that either list that role in their :roles arg or
     that don't have a :roles arg.
  1. If a job has a :roles arg but that role isn't in the whenever_roles list,
     that job *will not* be deployed to any server.

### RVM Integration

If your production environment uses RVM (Ruby Version Manager) you will run into a gotcha that causes your cron jobs to hang.  This is not directly related to Whenever, and can be tricky to debug.  Your .rvmrc files must be trusted or else the cron jobs will hang waiting for the file to be trusted.  A solution is to disable the prompt by adding this line to your user rvm file in `~/.rvmrc`

`rvm_trust_rvmrcs_flag=1`

This tells rvm to trust all rvmrc files.

### Heroku?

No. Heroku does not support cron, instead providing [Heroku Scheduler](https://devcenter.heroku.com/articles/scheduler). If you deploy to Heroku, you should use that rather than Whenever.

### Testing

[whenever-test](https://github.com/heartbits/whenever-test) is an extension to Whenever for testing a Whenever schedule.

### Credit

Whenever was created for use at Inkling (<http://inklingmarkets.com>). Their take on it: <http://blog.inklingmarkets.com/2009/02/whenever-easy-way-to-do-cron-jobs-from.html>

Thanks to all the contributors who have made it even better: <http://github.com/javan/whenever/contributors>

### Discussion / Feedback / Issues / Bugs

For general discussion and questions, please use the google group: <http://groups.google.com/group/whenever-gem>

If you've found a genuine bug or issue, please use the Issues section on github: <http://github.com/javan/whenever/issues>

Ryan Bates created a great Railscast about Whenever: <http://railscasts.com/episodes/164-cron-in-ruby>
It's a little bit dated now, but remains a good introduction.

----

[![Build Status](https://secure.travis-ci.org/javan/whenever.svg)](http://travis-ci.org/javan/whenever)

----

Copyright &copy; 2017 Javan Makhmali
