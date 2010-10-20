Capistrano::Configuration.instance(:must_exist).load do
  
  _cset(:whenever_roles)        { :db }
  _cset(:whenever_command)      { "whenever" }
  _cset(:whenever_identifier)   { application }
  _cset(:whenever_update_flags) { "--update-crontab #{whenever_identifier}" }
  _cset(:whenever_clear_flags)  { "--clear-crontab #{whenever_identifier}" }
  
  # Disable cron jobs at the begining of a deploy.
  after "deploy:update_code", "whenever:clear_crontab"
  # Write the new cron jobs near the end.
  after "deploy:symlink", "whenever:update_crontab"
  # If anything goes wrong, undo.
  after "deploy:rollback", "whenever:update_crontab"
  
  namespace :whenever do
    desc "Update application's crontab entries using Whenever"
    task :update_crontab, :roles => whenever_roles do
      # Hack by Jamis to skip a task if the role has no servers defined. http://tinyurl.com/ckjgnz
      next if find_servers_for_task(current_task).empty?
      run "cd #{current_path} && #{whenever_command} #{whenever_update_flags}"
    end

    desc "Clear application's crontab entries using Whenever"
    task :clear_crontab, :roles => whenever_roles do
      next if find_servers_for_task(current_task).empty?
      run "cd #{release_path} && #{whenever_command} #{whenever_clear_flags}"
    end
  end
  
end