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
    desc <<-DESC
      Update application's crontab entries using Whenever. You can configure \
      the command used to invoke Whenever by setting the :whenever_command \
      variable, which can be used with Bundler to set the command to \
      "bundle exec whenever". You can configure the identifier used by setting \
      the :whenever_identifier variable, which defaults to the same value configured \
      for the :application variable. You can configure the environment by setting \
      the :whenever_environment variable, which defaults to the same value \
      configured for the :rails_env variable which itself defaults to "production". \
      Finally, you can completely override all arguments to the Whenever command \
      by setting the :whenever_update_flags variable. Additionally you can configure \
      which servers the crontab is updated on by setting the :whenever_roles variable.
    DESC
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

    desc <<-DESC
      Clear application's crontab entries using Whenever. You can configure \
      the command used to invoke Whenever by setting the :whenever_command \
      variable, which can be used with Bundler to set the command to \
      "bundle exec whenever". You can configure the identifier used by setting \
      the :whenever_identifier variable, which defaults to the same value configured \
      for the :application variable. Finally, you can completely override all \
      arguments to the Whenever command by setting the :whenever_clear_flags variable. \
      Additionally you can configure which servers the crontab is cleared on by setting \
      the :whenever_roles variable.
    DESC

    task :clear_crontab do
      if servers.any?
        args = %w(command options clear_flags).inject({}) do |a, k|
          a[k.to_sym] = fetch("whenever_#{k}".to_sym)
        end
        args[:path] = fetch(:latest_release)

        run_whenever_commands(args)
      end
    end
  end
end
