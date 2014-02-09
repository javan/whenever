module Whenever
  module Capistrano
    def self.in_whenever_context
      on roles fetch(:whenever_roles) do |host|
        within release_path do
          with fetch(:whenever_command_environment_variables) do
            args = yield host
            if fetch(:whenever_command)
              execute fetch(:whenever_command), *args
            else
              execute :bundle, :exec, :whenever, *args
            end
          end
        end
      end
    end

    def self.whenever_command_args_for action
      in_whenever_context do |host|
        if :update == action
          args = [fetch(:whenever_update_flags), "--roles #{host.roles_array.join(',')}"]
        elsif :clear == action
          args = [fetch(:whenever_clear_flags)]
        end
      end
    end
  end
end

namespace :whenever do
  desc "Update application's crontab entries using Whenever"
  task :update_crontab do
    Whenever::Capistrano.whenever_command_args_for(:update)
  end

  desc "Clear application's crontab entries using Whenever"
  task :clear_crontab do
    Whenever::Capistrano.whenever_command_args_for(:clear)
  end

  after 'deploy:updated', 'whenever:update_crontab'
  after 'deploy:reverted', 'whenever:update_crontab'
  
end

namespace :load do
  task :defaults do
    set :whenever_command_environment_variables, ->{ {} }
    set :whenever_roles,        ->{ :db }
    set :whenever_options,      ->{ {:roles => fetch(:whenever_roles)} }
    set :whenever_command,      ->{  }
    set :whenever_identifier,   ->{ fetch :application }
    set :whenever_environment,  ->{ fetch :rails_env, "production" }
    set :whenever_variables,    ->{ "environment=#{fetch :whenever_environment}" }
    set :whenever_update_flags, ->{ "--update-crontab #{fetch :whenever_identifier} --set #{fetch :whenever_variables}" }
    set :whenever_clear_flags,  ->{ "--clear-crontab #{fetch :whenever_identifier}" }
  end
end
