namespace :whenever do
  desc "Update application's crontab entries using Whenever"
  task :update_crontab do
    on roles fetch(:whenever_roles) do
      within release_path do
        execute fetch(:whenever_command), fetch(:whenever_update_flags)
      end
    end
  end

  desc "Clear application's crontab entries using Whenever"
  task :clear_crontab do
    on roles fetch(:whenever_roles) do
      within release_path do
        execute %{#{fetch(:whenever_command)} #{fetch(:whenever_clear_flags)}}
      end
    end
  end

  after 'deploy:updated', 'whenever:update_crontab'
  after 'deploy:reverted', 'whenever:update_crontab'
  
end

namespace :load do
  task :defaults do
    set :whenever_roles,        ->{ :db }
    set :whenever_options,      ->{ {:roles => fetch(:whenever_roles)} }
    set :whenever_command,      ->{ :whenever }
    set :whenever_identifier,   ->{ fetch :application }
    set :whenever_environment,  ->{ fetch :rails_env, "production" }
    set :whenever_variables,    ->{ "environment=#{fetch :whenever_environment}" }
    set :whenever_update_flags, ->{ "--update-crontab #{fetch :whenever_identifier} --set #{fetch :whenever_variables}" }
    set :whenever_clear_flags,  ->{ "--clear-crontab #{fetch :whenever_identifier}" }
  end
end
