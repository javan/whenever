require "whenever/capistrano/recipes"

Capistrano::Configuration.instance(:must_exist).load do

  # Disable cron jobs at the begining of a deploy.
  before "deploy:update_code", "whenever:clear_crontab"
  # Write the new cron jobs near the end.
  after "deploy:finalize_update", "whenever:update_crontab"
  # If anything goes wrong, undo.
  after "deploy:rollback", "whenever:update_crontab"

end
