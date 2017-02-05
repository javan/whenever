require 'test_helper'

describe 'Executable' do
  describe 'bin/wheneverize' do
    describe 'ARGV is not empty' do
      describe 'file does not exist' do
        file = '/tmp/this_does_not_exist'

        it 'prints STDERR' do
          out, err = capture_subprocess_io do
            system('wheneverize', file)
          end

          assert_empty(out)
          assert_match(/`#{file}' does not exist./, err)
        end
      end

      describe 'file exists, but not a directory' do
        file = '/tmp/this_is_a_file.txt'
        before { FileUtils.touch(file) }

        it 'prints STDERR' do
          begin
            out, err = capture_subprocess_io do
              system('wheneverize', file)
            end

            assert_empty(out)
            assert_match(/`#{file}' is not a directory./, err)
          ensure
            FileUtils.rm(file)
          end
        end
      end

      describe 'file is a directory, but another param(s) are given as well' do
        file = '/tmp/this_is_a_directory'
        before { FileUtils.mkdir(file) }

        it 'prints STDERR' do
          begin
            out, err = capture_subprocess_io do
              system('wheneverize', file, 'another', 'parameters')
            end

            assert_empty(out)
            assert_match(/#{"Too many arguments; please specify only the " \
                         "directory to wheneverize."}/, err)
          ensure
            FileUtils.rmdir(file)
          end
        end
      end
    end

    describe 'ARGV is empty' do
      dir  = '.'
      file = 'config/schedule.rb'
      path = File.join(dir, file)

      describe 'config file already exists' do
        before do
          FileUtils.mkdir(File.dirname(path))
          FileUtils.touch(path)
        end

        it 'prints STDOUT and STDERR' do
          begin
            out, err = capture_subprocess_io do
              system('wheneverize')
            end

            assert_match(/\[done\] wheneverized!/, out)
            assert_match(/\[skip\] `#{path}' already exists/, err)
          ensure
            FileUtils.rm_rf(File.dirname(path))
          end
        end
      end

      describe 'config directory does not exist' do
        it 'prints STDOUT and STDERR' do
          begin
            out, err = capture_subprocess_io do
              system('wheneverize')
            end

            assert_match(/\[add\] creating `#{File.dirname(path)}'\n/, err)
            assert_match(/\[done\] wheneverized!/, out)
          ensure
            FileUtils.rm_rf(File.dirname(path))
          end
        end
      end

      describe 'config directory exists, but file does not' do
        before { FileUtils.mkdir(File.dirname(path)) }

        it 'writes config file and prints STDOUT' do
          begin
            out, err = capture_subprocess_io do
              system('wheneverize')
            end

            assert_empty(err)
            assert_match(
              /\[add\] writing `#{path}'\n\[done\] wheneverized!/,
              out
            )

            assert_match((<<-FILE
# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
FILE
                         ), IO.read(path))
          ensure
            FileUtils.rm_rf(File.dirname(path))
          end
        end
      end
    end
  end
end
