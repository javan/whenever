### unreleased

### 1.0.0 / Jun 13, 2019

* First stable release per SemVer.

* Removes support for versions of Ruby which are no longer supported by the Ruby project.

### 0.11.0 / April 23, 2019

* Add support for mapping Range objects to cron range syntax [Tim Craft](https://github.com/javan/whenever/pull/725)

* Bugfix: Avoid modifying Capistrano `default_env` when setting the whenever environment. [ta1kt0me](https://github.com/javan/whenever/pull/728)

* Enable to execute whenever's task independently without setting :release_path or :whenever_path [ta1kt0me](https://github.com/javan/whenever/pull/729)

* Make error message clearer when parsing cron syntax fails due to a trailing space [ignisf](https://github.com/javan/whenever/pull/744)

### 0.10.0 / November 19, 2017

* Modify wheneverize to allow for the creating of 'config' directory when not present

* Add --crontab-command to whenever binary for overriding the crontab command. [Martin Grandrath]

* Allow setting the path within which Capistrano will execute whenever. [Samuel Johnson](https://github.com/javan/whenever/pull/619)

* Allow the use of string literals for month and day-of-week in raw cron syntax.. [Potamianos Gregory](https://github.com/javan/whenever/pull/711)

* Include Capistrano default environment variables when executing Whenever. [Karl Li](https://github.com/javan/whenever/pull/719)

* Allow configuring an alternative schedule file in Capistrano. [Shinichi Okamoto](https://github.com/javan/whenever/pull/666)

* Add customizing email recipient option with the MAILTO environment variable. [Chikahiro Tokoro](https://github.com/javan/whenever/pull/678)

### 0.9.7 / June 14, 2016

* Restore compatibility with Capistrano v3; it has a bug which we have to work around [Ben Langfeld, Chris Gunther, Shohei Yamasaki]

### 0.9.6 / June 13, 2016

* Bypass symlinks when loading Capistrano v3 code, since these symlinks don't work in recent gem releases [Justin Ramos]

### 0.9.5 / June 12, 2016

* Improve documentation [Ben Langfeld, Spencer Fry]

* Properly support Solaris / SmartOS [Steven Williamson]

* Drop support for Ruby < 1.9.3. Test newer Ruby versions. [Javan Makhmali, Bartłomiej Kozal]

* Suport Ruby 2.3.0 and Rails 4 [Vincent Boisard]

* Set `RAILS_ENV` correctly in schedule when writing crontab from Capistrano [Ben Langfeld, Lorenzo Manacorda]

* Minor refactoring, avoidance of Ruby warnings, etc [Ben Langfeld, DV Dasari]

* Correctly pass through date expressions (e.g. `1.day`) inside job definitions [Rafael Sales]

* Prevent writing invalid cron strings [Danny Fallon, Ben Langfeld]

* Execute runner with `bundle exec` to ensure presence of app dependencies [Judith Roth]


### 0.9.4 / October 24, 2014

* Fix duplicated command line arguments when deploying to multiple servers with Cap 3. [betesh]

* Set `whenever_environment` to the current stage before defaulting to production in Cap 3 tasks. [Karthik T]


### 0.9.3 / October 5, 2014

* Drop ActiveSupport dependency [James Healy, Javan Makhmali]

* Drop shoulda for tests

* Fix `whenever:clear_crontab` Cap 3 task [Javan Makhmali]

* Avoid using tempfiles [ahoward]


### 0.9.2 / March 4, 2014

* Fix issues generating arguments for `execute` in Capistrano 3 tasks. [Javan Makhmali]


### 0.9.1 / March 2, 2014

* Pass `--roles` option to `whenever` in Capistrano 3 tasks. [betesh, Javan Makhmali]

* Allow setting `:whenever_command` for Capistrano 3. [Javan Makhmali]

* Allow `:whenever` command to be mapped in SSHKit. [Javan Makhmali]


### 0.9.0 / December 17, 2013

* Capistrano V3 support. [Philip Hallstrom]

* Process params in job templates. [Austin Ziegler]


### 0.8.4 / July 22, 2012

* Don't require schedule file when clearing. [Javan Makhmali]

* Use bin/rails when available. [Javan Makhmali]


### 0.8.3 / July 11, 2013

* Improve Cap rollback logic. [Jeroen Jacobs]

* Allow configuration of the environment variable. [andfx]

* Output option can be a callable Proc. [Li Xiao]


### 0.8.2 / January 10, 2013

* Fix Capistrano host options. [Igor Yamolov, Wes Morgan]

* Improve JRuby test support. [Igor Yamolov]

* Use correct release path in Cap task. [Wes Morgan]


### 0.8.1 / December 22nd, 2012

* Fix multiserver roles bug. [Wes Morgan]

* Refactor Cap recipes and add tests for them. [Wes Morgan]

* Fix file not found error when running under JRuby. [Wes Morgan]

* Stop interpolating template attributes with no corresponding value. [Vincent Boisard]

* Support for raw cron separated by tabs. [Étienne Barrié]


### 0.8.0 / November 8th, 2012

* Separate Capistrano recipes to allow custom execution. [Bogdan Gusiev]

* Execute `whenever:update_crontab` before `deploy:finalize_update`, not `deploy:restart`. [Michal Wrobel]

* Added a new `script` job type. [Ján Suchal]

* Use correct path in Cap task. [Alex Dean]

* Fix that setup.rb and schedule.rb were eval'd together. [Niklas H]

* New Capistrano roles feature. [Wes Morgan]

* Stop clearing the crontab during a deploy. [Javan Makhmali]

* Bump Chronic gem dependency. [rainchen]


### 0.7.3 / February 23rd, 2012

* Make included Capistrano task compatible with both new and old versions of Cap. [Giacomo Macrì]


### 0.7.2 / December 23rd, 2011

* Accept @reboot and friends as raw cron syntax. [Felix Buenemann]

* Fix clear_crontab task so it will work both standalone and during deploy. [Justin Giancola]


### 0.7.1 / December 19th, 2011

* Require thread before active_support for compatibility with Rails < 2.3.11 and RubyGems >= 1.6.0. [Micah Geisel]

* More advanced role filtering in Cap task. [Brad Gessler]

* Added whenever_variables as a configuration variable in Cap task. [Steve Agalloco]

* Escape percent signs and reject newlines in jobs. [Amir Yalon]

* Escape paths so spaces don't trip up cron. [Javan Makhmali]

* Fix ambiguous handling of 1.month with :at. #99 [Javan Makhmali]


### 0.7.0 / September 2nd, 2011

* Use mojombo's chronic, it's active again. [Javan Makhmali]

* Capistrano task enhancements. [Chris Griego]

* wheneverize command defaults to '.' directory. [Andrew Nesbitt]

* rake job_type uses bundler if detected. [Michał Szajbe]

* Indicate filename in exceptions stemming from schedule file. [Javan Makhmali]

* Don't require rubygems, bundler where possible. [Oleg Pudeyev]

* Documentation and code cleanup. [many nice people]


### 0.6.8 / May 24th, 2011

* Convert most shortcuts to seconds. every :day -> every 1.day. #129 [Javan Makhmali]

* Allow commas in raw cron syntax. #130 [Marco Bergantin, Javan Makhmali]

* Output no update message as comments. #135 [Javan Makhmali]

* require 'thread' to support Rubygems >= 1.6.0. #132 [Javan Makhmali]


### 0.6.7 / March 23rd, 2011

* Fix issue with comment block being corrupted during subsequent insertion of duplicate entries to the crontab. #123 [Jeremy (@lingmann)]

* Removed -i from default job template. #118 [Javan Makhmali]


### 0.6.6 / March 8th, 2011

* Fix unclosed identifier bug. #119 [Javan Makhmali]


### 0.6.5 / March 8th, 2011

* Preserve whitespace at the end of crontab file. #95 [Rich Meyers]

* Setting nil or blank environment variables now properly formats output. [T.J. VanSlyke]

* Allow raw cron sytax, added -i to bash job template, general cleanup. [Javan Makhmali]


### 0.6.2 / October 26th, 2010

* --clear-crontab option completely removes entries. #63 [Javan Makhmali]

* Set default :environment and :path earlier in the new setup.rb (formerly job_types/default.rb). [Javan Makhmali]

* Converted README and CHANGELOG to markdown. [Javan Makhmali]


### 0.6.1 / October 20th, 2010

* Detect script/rails file and change runner to Rails 3 style if found. [Javan Makhmali]

* Created a new :job_template system that can be applied to all commands. Wraps all in bash -l -c 'command..' by default now for better RVM support. Stopped automatically setting the PATH too. [Javan Makhmali]

* Added a built-in Capistrano recipe. [Javan Makhmali]


### 0.5.3 / September 24th, 2010

* Better regexes for replacing Whenever blocks in the crontab. #45 [Javan Makhmali]

* Preserving backslashes when updating existing crontab. #82 [Javan Makhmali]


### 0.5.2 / September 15th, 2010

* Quotes automatically escaped in jobs. [Jay Adkisson]

* Added --cut option to the command line to allow pruning of the crontab. [Peer Allan]

* Switched to aaronh-chronic which is ruby 1.9.2 compatible. [Aaron Hurley, Javan Makhmali]

* Lots of internal reorganizing; tests broken into unit and functional. [Javan Makhmali]


### 0.5.0 / June 28th, 2010

* New job_type API for writing custom jobs. Internals use this to define command, runner, and rake. [Javan Makhmali - inspired by idlefingers (Damien)]

* Jobs < 1.hour can specify an :at. [gorenje]

* --clear option to remove crontab entries for a specific [identifier]. [mraidel (Michael Raidel)]


### 0.4.2 / April 26th, 2010

* runners now cd into the app's directory and then execute. [Michael Guterl]

* Fix STDERR output redirection to file to append instead of overwrite. [weplay]

* Move require of tempfile lib to file that actually uses it. [Finn Smith]

* bugfix: comparison Time with 0 failed. #32 [Dan Hixon]


### 0.4.1 / November 30th, 2009

* exit(0) instead of just exit to make JRuby happy. [Elan Meng]

* Fixed activesupport deprecation warning by requiring active_support. #37 [Andrew Nesbitt]


### 0.4.0 / October 20th, 2009

* New output option replaces the old cron_log option for output redirection and is much more flexible. #31 [Peer Allan]

* Reorganized the lib files (http://weblog.rubyonrails.org/2009/9/1/gem-packaging-best-practices) and switched to Jeweler from Echoe.


### 0.3.7 / September 4th, 2009

* No longer tries (and fails) to combine @shortcut jobs. #20 [Javan Makhmali]


### 0.3.6 / June 15th, 2009

* Setting a PATH in the crontab automatically based on the user's PATH. [Javan Makhmali]


### 0.3.5 / June 13th, 2009

* Added ability to accept lists of every's and at's and intelligently group them. (ex: every 'monday, wednesday', :at => ['3pm', '6am']). [Sam Ruby]

* Fixed issue with new lines. #18 [Javan Makhmali]

### 0.3.1 / June 25th, 2009

* Removed activesupport gem dependency. #1 [Javan Makhmali]

* Switched to numeric days of the week for Solaris support (and probably others). #8 [Roger Ertesvåg]


### 0.3.0 / June 2nd, 2009

* Added ability to set variables on the fly from the command line (ex: whenever --set environment=staging). [Javan Makhmali]


### 0.2.2 / April 30th, 2009

* Days of week jobs can now accept an :at directive (ex: every :monday, :at => '5pm'). [David Eisinger]

* Fixed command line test so it runs without a config/schedule.rb present. [Javan Makhmali]

* Raising an exception if someone tries to specify an :at with a cron shortcut (:day, :reboot, etc) so there are no false hopes. [Javan Makhmali]


### 0.1.7 / March 5th, 2009

* Added ability to update the crontab file non-destuctively instead of only overwriting it. [Javan Makhmali -- Inspired by code submitted individually from: Tien Dung (tiendung), Tom Lea (cwninja), Kyle Maxwell (fizx), and Andrew Timberlake (andrewtimberlake) on github]


### 0.1.5 / February 19th, 2009

* Fixed load path so Whenever's files don't conflict with anything in Rails. Thanks Ryan Koopmans. [Javan Makhmali]


### 0.1.4 / February 17th, 2009

* Added --load-file and --user opts to whenever binary. [Javan Makhmali]


### 0.1.3 / February 16th, 2009

* Added 'rake' helper for defining scheduled rake tasks. [Javan Makhmali]

* Renamed :cron_environment and :cron_path to :enviroment and :path for better (word) compatibility with rake tasks. [Javan Makhmali]

* Improved test load paths so tests can be run individually. [Javan Makhmali]

* Got rid of already initialized constant warning. [Javan Makhmali]

* Requiring specific gem versions: Chronic >=0.2.3 and activesupport >= 1.3.0 [Javan Makhmali]


### 0.1.0 / February 15th, 2009

* Initial release [Javan Makhmali]
