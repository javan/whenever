Capistrano::Configuration.instance(:must_exist).load do
  _cset(:whenever_roles)        { :db }
  _cset(:whenever_command)      { "whenever" }
  _cset(:whenever_identifier)   { fetch :application }
  _cset(:whenever_environment)  { fetch :rails_env, "production" }
  _cset(:whenever_update_flags) { "--update-crontab #{fetch :whenever_identifier} --set environment=#{fetch :whenever_environment}" }
  _cset(:whenever_clear_flags)  { "--clear-crontab #{fetch :whenever_identifier}" }

  # Disable cron jobs at the begining of a deploy.
  after "deploy:update_code", "whenever:clear_crontab"
  # Write the new cron jobs near the end.
  after "deploy:symlink", "whenever:update_crontab"
  # If anything goes wrong, undo.
  after "deploy:rollback", "whenever:update_crontab"

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
      options = { :roles => fetch(:whenever_roles) }

      if find_servers(options).any?
        on_rollback do
          if fetch :previous_release
            run "cd #{fetch :previous_release} && #{fetch :whenever_command} #{fetch :whenever_update_flags}", options
          else
            run "cd #{fetch :release_path} && #{fetch :whenever_command} #{fetch :whenever_clear_flags}", options
          end
        end

        run "cd #{fetch :current_path} && #{fetch :whenever_command} #{fetch :whenever_update_flags}", options
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
      options = { :roles => whenever_roles }
      run "cd #{fetch :release_path} && #{fetch :whenever_command} #{fetch :whenever_clear_flags}", options if find_servers(options).any?
    end
  end
end
