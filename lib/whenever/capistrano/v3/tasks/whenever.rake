namespace :whenever do
  def setup_whenever_task(*args, &block)
    args = Array(fetch(:whenever_command)) + args

    on roles fetch(:whenever_roles) do |host|
      host_args = Array(yield(host))
      within release_path do
        with fetch(:whenever_command_environment_variables) do
          execute *(args + host_args)
        end
      end
    end
  end

  desc "Update application's crontab entries using Whenever"
  task :update_crontab do
    setup_whenever_task do |host|
      roles = host.roles_array.join(",")
      [fetch(:whenever_update_flags),  "--roles=#{roles}"]
    end
  end

  desc "Clear application's crontab entries using Whenever"
  task :clear_crontab do
    setup_whenever_task(fetch(:whenever_clear_flags))
  end

  after "deploy:updated",  "whenever:update_crontab"
  after "deploy:reverted", "whenever:update_crontab"
end

namespace :load do
  task :defaults do
    set :whenever_roles,        ->{ :db }
    set :whenever_command,      ->{ [:bundle, :exec, :whenever] }
    set :whenever_command_environment_variables, ->{ {} }
    set :whenever_identifier,   ->{ fetch :application }
    set :whenever_environment,  ->{ fetch :rails_env, "production" }
    set :whenever_variables,    ->{ "environment=#{fetch :whenever_environment}" }
    set :whenever_update_flags, ->{ "--update-crontab #{fetch :whenever_identifier} --set #{fetch :whenever_variables}" }
    set :whenever_clear_flags,  ->{ "--clear-crontab #{fetch :whenever_identifier}" }
  end
end
