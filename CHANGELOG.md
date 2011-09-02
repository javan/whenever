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