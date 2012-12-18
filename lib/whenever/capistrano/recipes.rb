require 'whenever/capistrano/support'

Capistrano::Configuration.instance(:must_exist).load do
  include Whenever::CapistranoSupport

  _cset(:whenever_roles)        { :db }
  _cset(:whenever_options)      { {:roles => fetch(:whenever_roles)} }
  _cset(:whenever_command)      { "whenever" }
  _cset(:whenever_identifier)   { fetch :application }
  _cset(:whenever_environment)  { fetch :rails_env, "production" }
  _cset(:whenever_variables)    { "environment=#{fetch :whenever_environment}" }
  _cset(:whenever_update_flags) { "--update-crontab #{fetch :whenever_identifier} --set #{fetch :whenever_variables}" }
  _cset(:whenever_clear_flags)  { "--clear-crontab #{fetch :whenever_identifier}" }

  namespace :whenever do
    desc "Update application's crontab entries using Whenever"
    task :update_crontab do
      args[:command] = fetch(:whenever_command)
      args[:flags]   = fetch(:whenever_update_flags)
      args[:path]    = fetch(:release_path)

      if servers.any?
        run_whenever_commands(args)

        on_rollback do
          if fetch(:previous_release)
            # rollback to the previous release's crontab
            args[:path] = fetch(:previous_release)
          else
            # clear the crontab if no previous release
            args[:flags] = fetch(:whenever_clear_flags)
          end

          run_whenever_commands(args)
        end
      end
    end

    desc "Clear application's crontab entries using Whenever"
    task :clear_crontab do
      if servers.any?
        args[:command] = fetch(:whenever_command)
        args[:flags]   = fetch(:whenever_clear_flags)
        args[:path]    = fetch(:latest_release)

        run_whenever_commands(args)
      end
    end
  end
end
