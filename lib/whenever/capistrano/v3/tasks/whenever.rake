namespace :whenever do
  def setup_whenever_task(*args, &block)
    args = Array(fetch(:whenever_command)) + args

    on roles fetch(:whenever_roles) do |host|
      args_for_host = block_given? ? args + Array(yield(host)) : args
      within fetch(:whenever_path) do
        with fetch(:whenever_command_environment_variables) do
          execute(*args_for_host)
        end
      end
    end
  end

  def load_file
    file = fetch(:whenever_load_file)
    if file
      "-f #{file}"
    else
      ''
    end
  end

  desc "Update application's crontab entries using Whenever"
  task :update_crontab do
    setup_whenever_task do |host|
      roles = host.roles_array.join(",")
      [fetch(:whenever_update_flags), "--roles=#{roles}", load_file]
    end
  end

  desc "Clear application's crontab entries using Whenever"
  task :clear_crontab do
    setup_whenever_task do |host|
      [fetch(:whenever_clear_flags), load_file]
    end
  end

  after "deploy:updated",  "whenever:update_crontab"
  after "deploy:reverted", "whenever:update_crontab"
end

namespace :load do
  task :defaults do
    set :whenever_roles,        ->{ :db }
    set :whenever_command,      ->{ [:bundle, :exec, :whenever] }
    set :whenever_command_environment_variables, ->{ fetch(:default_env).merge!(rails_env: fetch(:whenever_environment)) }
    set :whenever_identifier,   ->{ fetch :application }
    set :whenever_environment,  ->{ fetch :rails_env, fetch(:stage, "production") }
    set :whenever_variables,    ->{ "environment=#{fetch :whenever_environment}" }
    set :whenever_load_file,    ->{ nil }
    set :whenever_update_flags, ->{ "--update-crontab #{fetch :whenever_identifier} --set #{fetch :whenever_variables}" }
    set :whenever_clear_flags,  ->{ "--clear-crontab #{fetch :whenever_identifier}" }
    set :whenever_path,         ->{ fetch :release_path }
  end
end
