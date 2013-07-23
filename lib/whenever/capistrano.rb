require "whenever/capistrano/recipes"

Capistrano::Configuration.instance(:must_exist).load do
  # Write the new cron jobs near the end.
  before "deploy:create_symlink", "whenever:update_crontab"
  # If anything goes wrong, undo.
  after "deploy:rollback", "whenever:update_crontab"
end
