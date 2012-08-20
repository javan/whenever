Capistrano::Configuration.instance(:must_exist).load do
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
      options = fetch(:whenever_options)
      roles = [options[:roles]].flatten if options[:roles]

      if find_servers(options).any?
        # make sure we go through the roles.each loop at least once
        roles << :__none if roles.empty?

        roles.each do |role|
          if role == :__none
            role_arg = ''
          else
            options[:roles] = role
            role_arg = " --server-roles #{role}"
          end

          on_rollback do
            if fetch :previous_release
              run "cd #{fetch :previous_release} && #{fetch :whenever_command} #{fetch :whenever_update_flags}#{role_arg}", options
            else
              run "cd #{fetch :release_path} && #{fetch :whenever_command} #{fetch :whenever_clear_flags}", options
            end
          end

          run "cd #{fetch :current_path} && #{fetch :whenever_command} #{fetch :whenever_update_flags}#{role_arg}", options
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
      options = fetch(:whenever_options)
      run "cd #{fetch :latest_release} && #{fetch :whenever_command} #{fetch :whenever_clear_flags}", options if find_servers(options).any?
    end
  end
end
