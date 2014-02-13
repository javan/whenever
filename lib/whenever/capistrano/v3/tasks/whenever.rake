namespace :deploy do
  before :starting, :check_whenever_hooks do
    invoke 'whenever:add_default_hooks' if fetch(:whenever_default_hooks)
  end
end

namespace :whenever do
  desc "Update application's crontab entries using Whenever"
  task :update_crontab do
    on roles fetch(:whenever_roles) do
      within release_path do
        if fetch(:whenever_command)
          execute fetch(:whenever_command), fetch(:whenever_update_flags)
        else
          execute :bundle, :exec, :whenever, fetch(:whenever_update_flags)
        end
      end
    end
  end

  desc "Clear application's crontab entries using Whenever"
  task :clear_crontab do
    on roles fetch(:whenever_roles) do
      within release_path do
        if fetch(:whenever_command)
          execute %{#{fetch(:whenever_command)} #{fetch(:whenever_clear_flags)}}
        else
          execute :bundle, :exec, :whenever, fetch(:whenever_clear_flags)
        end
      end
    end
  end

  task :add_default_hooks do
    after 'deploy:updated', 'whenever:update_crontab'
    after 'deploy:reverted', 'whenever:update_crontab'
  end
end

namespace :load do
  task :defaults do
    set :whenever_roles,         ->{ :db }
    set :whenever_options,       ->{ {:roles => fetch(:whenever_roles)} }
    set :whenever_command,       ->{  }
    set :whenever_identifier,    ->{ fetch :application }
    set :whenever_environment,   ->{ fetch :rails_env, "production" }
    set :whenever_variables,     ->{ "environment=#{fetch :whenever_environment}" }
    set :whenever_update_flags,  ->{ "--update-crontab #{fetch :whenever_identifier} --set #{fetch :whenever_variables}" }
    set :whenever_clear_flags,   ->{ "--clear-crontab #{fetch :whenever_identifier}" }
    set :whenever_default_hooks, ->{ true }
  end
end
