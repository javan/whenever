require 'test_helper'

class CommandLineWriteTest < Whenever::TestCase
  setup do
    Time.stubs(:now).returns(Time.new(2017, 2, 24, 16, 21, 30, '+01:00'))
    File.expects(:exist?).with('config/schedule.rb').returns(true)
    @command = Whenever::CommandLine.new(:write => true, :identifier => 'My identifier')
    @task = "#{two_hours} /my/command"
    Whenever.expects(:cron).returns(@task)
  end

  should "output the cron job with identifier blocks" do
    output = <<-EXPECTED
# Begin Whenever generated tasks for: My identifier at: 2017-02-24 16:21:30 +0100
#{@task}
# End Whenever generated tasks for: My identifier at: 2017-02-24 16:21:30 +0100
EXPECTED

    assert_equal output, @command.send(:whenever_cron)
  end

  should "write the crontab when run" do
    @command.expects(:write_crontab).returns(true)
    assert @command.run
  end
end

class CommandLineUpdateTest < Whenever::TestCase
  setup do
    Time.stubs(:now).returns(Time.new(2017, 2, 24, 16, 21, 30, '+01:00'))
    File.expects(:exist?).with('config/schedule.rb').returns(true)
    @command = Whenever::CommandLine.new(:update => true, :identifier => 'My identifier')
    @task = "#{two_hours} /my/command"
    Whenever.expects(:cron).returns(@task)
  end

  should "add the cron to the end of the file if there is no existing identifier block" do
    existing = '# Existing crontab'
    @command.expects(:read_crontab).at_least_once.returns(existing)

    new_cron = <<-EXPECTED
#{existing}

# Begin Whenever generated tasks for: My identifier at: 2017-02-24 16:21:30 +0100
#{@task}
# End Whenever generated tasks for: My identifier at: 2017-02-24 16:21:30 +0100
EXPECTED

    assert_equal new_cron, @command.send(:updated_crontab)

    @command.expects(:write_crontab).with(new_cron).returns(true)
    assert @command.run
  end

  should "replace an existing block if the identifier matches and the timestamp doesn't" do
    existing = <<-EXISTING_CRON
# Something

# Begin Whenever generated tasks for: My identifier at: 2017-01-03 08:02:22 +0500
My whenever job that was already here
# End Whenever generated tasks for: My identifier at: 2017-01-03 08:22:22 +0500

# Begin Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
This shouldn't get replaced
# End Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
EXISTING_CRON

    new_cron = <<-NEW_CRON
# Something

# Begin Whenever generated tasks for: My identifier at: 2017-02-24 16:21:30 +0100
#{@task}
# End Whenever generated tasks for: My identifier at: 2017-02-24 16:21:30 +0100

# Begin Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
This shouldn't get replaced
# End Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
NEW_CRON

    @command.expects(:read_crontab).at_least_once.returns(existing)
    assert_equal new_cron, @command.send(:updated_crontab)

    @command.expects(:write_crontab).with(new_cron).returns(true)
    assert @command.run
  end

  should "replace an existing block if the identifier matches and the UTC timestamp doesn't" do
    existing = <<-EXISTING_CRON
# Something

# Begin Whenever generated tasks for: My identifier at: 2017-01-03 08:02:22 UTC
My whenever job that was already here
# End Whenever generated tasks for: My identifier at: 2017-01-03 08:22:22 UTC

# Begin Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
This shouldn't get replaced
# End Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
EXISTING_CRON

    new_cron = <<-NEW_CRON
# Something

# Begin Whenever generated tasks for: My identifier at: 2017-02-24 16:21:30 +0100
#{@task}
# End Whenever generated tasks for: My identifier at: 2017-02-24 16:21:30 +0100

# Begin Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
This shouldn't get replaced
# End Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
NEW_CRON

    @command.expects(:read_crontab).at_least_once.returns(existing)
    assert_equal new_cron, @command.send(:updated_crontab)

    @command.expects(:write_crontab).with(new_cron).returns(true)
    assert @command.run
  end

  should "replace an existing block if the identifier matches and it doesn't contain a timestamp" do
    existing = <<-EXISTING_CRON
# Something

# Begin Whenever generated tasks for: My identifier
My whenever job that was already here
# End Whenever generated tasks for: My identifier

# Begin Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
This shouldn't get replaced
# End Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
EXISTING_CRON

    new_cron = <<-NEW_CRON
# Something

# Begin Whenever generated tasks for: My identifier at: 2017-02-24 16:21:30 +0100
#{@task}
# End Whenever generated tasks for: My identifier at: 2017-02-24 16:21:30 +0100

# Begin Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
This shouldn't get replaced
# End Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
NEW_CRON

    @command.expects(:read_crontab).at_least_once.returns(existing)
    assert_equal new_cron, @command.send(:updated_crontab)

    @command.expects(:write_crontab).with(new_cron).returns(true)
    assert @command.run
  end
end

class CommandLineUpdateWithBackslashesTest < Whenever::TestCase
  setup do
    Time.stubs(:now).returns(Time.new(2017, 2, 24, 16, 21, 30, '+01:00'))
    @existing = <<-EXISTING_CRON
# Begin Whenever generated tasks for: My identifier at: 2017-02-24 16:21:30 +0100
script/runner -e production 'puts '\\''hello'\\'''
# End Whenever generated tasks for: My identifier at: 2017-02-24 16:21:30 +0100
EXISTING_CRON
    File.expects(:exist?).with('config/schedule.rb').returns(true)
    @command = Whenever::CommandLine.new(:update => true, :identifier => 'My identifier')
    @command.expects(:read_crontab).at_least_once.returns(@existing)
    @command.expects(:whenever_cron).returns(@existing)
  end

  should "replace the existing block with the backslashes in tact" do
    assert_equal @existing, @command.send(:updated_crontab)
  end
end

class CommandLineUpdateToSimilarCrontabTest < Whenever::TestCase
  setup do
    @existing = <<-EXISTING_CRON
# Begin Whenever generated tasks for: WheneverExisting at: 2017-02-24 16:21:30 +0100
# End Whenever generated tasks for: WheneverExisting at: 2017-02-24 16:21:30 +0100
EXISTING_CRON
    @new = <<-NEW_CRON
# Begin Whenever generated tasks for: Whenever at: 2017-02-24 16:21:30 +0100
# End Whenever generated tasks for: Whenever at: 2017-02-24 16:21:30 +0100
NEW_CRON
    File.expects(:exist?).with('config/schedule.rb').returns(true)
    @command = Whenever::CommandLine.new(:update => true, :identifier => 'Whenever')
    @command.expects(:read_crontab).at_least_once.returns(@existing)
    @command.expects(:whenever_cron).returns(@new)
  end

  should "append the similarly named command" do
    assert_equal @existing + "\n" + @new, @command.send(:updated_crontab)
  end
end

class CommandLineClearTest < Whenever::TestCase
  setup do
    Time.stubs(:now).returns(Time.new(2017, 2, 24, 16, 21, 30, '+01:00'))
    File.expects(:exist?).with('config/schedule.rb').returns(true)
    @command = Whenever::CommandLine.new(:clear => true, :identifier => 'My identifier')
    @task = "#{two_hours} /my/command"
  end

  should "clear an existing block if the identifier matches and the timestamp doesn't" do
    existing = <<-EXISTING_CRON
# Something

# Begin Whenever generated tasks for: My identifier at: 2017-01-03 08:20:02 +0500
My whenever job that was already here
# End Whenever generated tasks for: My identifier at: 2017-01-03 08:20:02 +0500

# Begin Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
This shouldn't get replaced
# End Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
EXISTING_CRON

    @command.expects(:read_crontab).at_least_once.returns(existing)

    new_cron = <<-NEW_CRON
# Something

# Begin Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
This shouldn't get replaced
# End Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
NEW_CRON

    assert_equal new_cron, @command.send(:updated_crontab)

    @command.expects(:write_crontab).with(new_cron).returns(true)
    assert @command.run
  end

  should "clear an existing block if the identifier matches and the UTC timestamp doesn't" do
    existing = <<-EXISTING_CRON
# Something

# Begin Whenever generated tasks for: My identifier at: 2017-01-03 08:20:02 UTC
My whenever job that was already here
# End Whenever generated tasks for: My identifier at: 2017-01-03 08:20:02 UTC

# Begin Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
This shouldn't get replaced
# End Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
EXISTING_CRON

    @command.expects(:read_crontab).at_least_once.returns(existing)

    new_cron = <<-NEW_CRON
# Something

# Begin Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
This shouldn't get replaced
# End Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
NEW_CRON

    assert_equal new_cron, @command.send(:updated_crontab)

    @command.expects(:write_crontab).with(new_cron).returns(true)
    assert @command.run
  end

  should "clear an existing block if the identifier matches and it doesn't have a timestamp" do
    existing = <<-EXISTING_CRON
# Something

# Begin Whenever generated tasks for: My identifier
My whenever job that was already here
# End Whenever generated tasks for: My identifier

# Begin Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
This shouldn't get replaced
# End Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
EXISTING_CRON

    @command.expects(:read_crontab).at_least_once.returns(existing)

    new_cron = <<-NEW_CRON
# Something

# Begin Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
This shouldn't get replaced
# End Whenever generated tasks for: Other identifier at: 2017-02-24 16:21:30 +0100
NEW_CRON

    assert_equal new_cron, @command.send(:updated_crontab)

    @command.expects(:write_crontab).with(new_cron).returns(true)
    assert @command.run
  end
end

class CommandLineClearWithNoScheduleTest < Whenever::TestCase
  setup do
    File.expects(:exist?).with('config/schedule.rb').returns(false)
    @command = Whenever::CommandLine.new(:clear => true, :identifier => 'My identifier')
  end

  should "run successfully" do
    @command.expects(:write_crontab).returns(true)
    assert @command.run
  end
end

class CommandLineUpdateWithNoIdentifierTest < Whenever::TestCase
  setup do
    Time.stubs(:now).returns(Time.new(2017, 2, 24, 16, 21, 30, '+01:00'))
    File.expects(:exist?).with('config/schedule.rb').returns(true)
    Whenever::CommandLine.any_instance.expects(:default_identifier).returns('DEFAULT')
    @command = Whenever::CommandLine.new(:update => true)
  end

  should "use the default identifier" do
    assert_equal "Whenever generated tasks for: DEFAULT at: 2017-02-24 16:21:30 +0100", @command.send(:comment_base)
  end
end

class CombinedParamsTest < Whenever::TestCase
  setup do
    Whenever::CommandLine.any_instance.expects(:exit)
    Whenever::CommandLine.any_instance.expects(:warn)
    File.expects(:exist?).with('config/schedule.rb').returns(true)
  end

  should "exit with write and clear" do
    @command = Whenever::CommandLine.new(:write => true, :clear => true)
  end

  should "exit with write and update" do
    @command = Whenever::CommandLine.new(:write => true, :update => true)
  end

  should "exit with update and clear" do
    @command = Whenever::CommandLine.new(:update => true, :clear => true)
  end
end

class RunnerOverwrittenWithSetOptionTest < Whenever::TestCase
  setup do
    @output = Whenever.cron :set => 'environment=serious', :string => \
    <<-file
      set :job_template, nil
      set :environment, :silly
      set :path, '/my/path'
      every 2.hours do
        runner "blahblah"
      end
    file
  end

  should "output the runner using the override environment" do
    assert_match two_hours + %( cd /my/path && bundle exec script/runner -e serious 'blahblah'), @output
  end
end


class EnvironmentAndPathOverwrittenWithSetOptionTest < Whenever::TestCase
  setup do
    @output = Whenever.cron :set => 'environment=serious&path=/serious/path', :string => \
    <<-file
      set :job_template, nil
      set :environment, :silly
      set :path, '/silly/path'
      every 2.hours do
        runner "blahblah"
      end
    file
  end

  should "output the runner using the overridden path and environment" do
    assert_match two_hours + %( cd /serious/path && bundle exec script/runner -e serious 'blahblah'), @output
  end
end

class EnvironmentAndPathOverwrittenWithSetOptionWithSpacesTest < Whenever::TestCase
  setup do
    @output = Whenever.cron :set => ' environment = serious&  path =/serious/path', :string => \
    <<-file
      set :job_template, nil
      set :environment, :silly
      set :path, '/silly/path'
      every 2.hours do
        runner "blahblah"
      end
    file
  end

  should "output the runner using the overridden path and environment" do
    assert_match two_hours + %( cd /serious/path && bundle exec script/runner -e serious 'blahblah'), @output
  end
end

class EnvironmentOverwrittenWithoutValueTest < Whenever::TestCase
  setup do
    @output = Whenever.cron :set => ' environment=', :string => \
    <<-file
      set :job_template, nil
      set :environment, :silly
      set :path, '/silly/path'
      every 2.hours do
        runner "blahblah"
      end
    file
  end

  should "output the runner using the original environmnet" do
    assert_match two_hours + %( cd /silly/path && bundle exec script/runner -e silly 'blahblah'), @output
  end
end

class PreparingOutputTest < Whenever::TestCase
  setup do
    File.expects(:exist?).with('config/schedule.rb').returns(true)
  end

  should "not trim off the top lines of the file" do
    @command = Whenever::CommandLine.new(:update => true, :identifier => 'My identifier', :cut => 0)
    existing = <<-EXISTING_CRON
# Useless Comments
# at the top of the file

# Begin Whenever generated tasks for: My identifier at: 2017-02-24 16:21:30 +0100
My whenever job that was already here
# End Whenever generated tasks for: My identifier at: 2017-02-24 16:21:30 +0100
EXISTING_CRON

    assert_equal existing, @command.send(:prepare, existing)
  end

  should "trim off the top lines of the file" do
    @command = Whenever::CommandLine.new(:update => true, :identifier => 'My identifier', :cut => '3')
    existing = <<-EXISTING_CRON
# Useless Comments
# at the top of the file

# Begin Whenever generated tasks for: My identifier at: 2017-02-24 16:21:30 +0100
My whenever job that was already here
# End Whenever generated tasks for: My identifier at: 2017-02-24 16:21:30 +0100
EXISTING_CRON

    new_cron = <<-NEW_CRON
# Begin Whenever generated tasks for: My identifier at: 2017-02-24 16:21:30 +0100
My whenever job that was already here
# End Whenever generated tasks for: My identifier at: 2017-02-24 16:21:30 +0100
NEW_CRON

    assert_equal new_cron, @command.send(:prepare, existing)
  end

  should "preserve terminating newlines in files" do
    @command = Whenever::CommandLine.new(:update => true, :identifier => 'My identifier')
    existing = <<-EXISTING_CRON
# Begin Whenever generated tasks for: My identifier at: 2017-02-24 16:21:30 +0100
My whenever job that was already here
# End Whenever generated tasks for: My identifier at: 2017-02-24 16:21:30 +0100

# A non-Whenever task
My non-whenever job that was already here
EXISTING_CRON

    assert_equal existing, @command.send(:prepare, existing)
  end
end
