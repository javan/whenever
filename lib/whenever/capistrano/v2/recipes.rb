require 'whenever/capistrano/v2/support'

Capistrano::Configuration.instance(:must_exist).load do
  Whenever::CapistranoSupport.load_into(self)

  _cset(:whenever_roles)        { :db }
  _cset(:whenever_options)      { {:roles => fetch(:whenever_roles)} }
  _cset(:whenever_command)      { "whenever" }
  _cset(:whenever_identifier)   { fetch :application }
  _cset(:whenever_environment)  { fetch :rails_env, fetch(:stage, "production") }
  _cset(:whenever_variables)    { "environment=#{fetch :whenever_environment}" }
  _cset(:whenever_update_flags) { "--update-crontab #{fetch :whenever_identifier} --set #{fetch :whenever_variables}" }
  _cset(:whenever_clear_flags)  { "--clear-crontab #{fetch :whenever_identifier}" }
  _cset(:whenever_path)         { fetch :latest_release }

  namespace :whenever do
    desc "Update application's crontab entries using Whenever"
    task :update_crontab do
      args = {
        :command => fetch(:whenever_command),
        :flags   => fetch(:whenever_update_flags),
        :path    => fetch(:whenever_path)
      }

      if whenever_servers.any?
        args = whenever_prepare_for_rollback(args) if task_call_frames[0].task.fully_qualified_name == 'deploy:rollback'
        whenever_run_commands(args)

        on_rollback do
          args = whenever_prepare_for_rollback(args)
          whenever_run_commands(args)
        end
      end
    end

    desc "Clear application's crontab entries using Whenever"
    task :clear_crontab do
      if whenever_servers.any?
        args = {
          :command => fetch(:whenever_command),
          :flags   => fetch(:whenever_clear_flags),
          :path    => fetch(:whenever_path)
        }

        whenever_run_commands(args)
      end
    end
  end
end
