require "whenever/capistrano/recipes"

Capistrano::Configuration.instance(:must_exist).load do

  # Disable cron jobs at the begining of a deploy.
  after "deploy:update_code", "whenever:clear_crontab"
  # Write the new cron jobs near the end.
  before "deploy:restart", "whenever:update_crontab"
  # If anything goes wrong, undo.
  after "deploy:rollback", "whenever:update_crontab"

end
