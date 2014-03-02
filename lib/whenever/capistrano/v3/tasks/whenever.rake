namespace :whenever do
  def setup_whenever_task
    SSHKit.config.command_map[:whenever] = fetch(:whenever_command)

    on roles fetch(:whenever_roles) do |host|
      within release_path do
        execute :whenever, *Array(yield(host))
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
    setup_whenever_task do
      fetch(:whenever_clear_flags)
    end
  end

  after "deploy:updated",  "whenever:update_crontab"
  after "deploy:reverted", "whenever:update_crontab"
end

namespace :load do
  task :defaults do
    set :whenever_roles,        ->{ :db }
    set :whenever_command,      ->{ "bundle exec whenever" }
    set :whenever_identifier,   ->{ fetch :application }
    set :whenever_environment,  ->{ fetch :rails_env, "production" }
    set :whenever_variables,    ->{ "environment=#{fetch :whenever_environment}" }
    set :whenever_update_flags, ->{ "--update-crontab #{fetch :whenever_identifier} --set #{fetch :whenever_variables}" }
    set :whenever_clear_flags,  ->{ "--clear-crontab #{fetch :whenever_identifier}" }
  end
end
