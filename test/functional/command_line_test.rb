require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class CommandLineTest < Test::Unit::TestCase

  context "A command line write" do
    setup do
      File.expects(:exists?).with('config/schedule.rb').returns(true)
      @command = Whenever::CommandLine.new(:write => true, :identifier => 'My identifier')
      @task = "#{two_hours} /my/command"
      Whenever.expects(:cron).returns(@task)
    end

    should "output the cron job with identifier blocks" do
      output = <<-EXPECTED
# Begin Whenever generated tasks for: My identifier
#{@task}
# End Whenever generated tasks for: My identifier
EXPECTED

      assert_equal output, @command.send(:whenever_cron)
    end

    should "write the crontab when run" do
      @command.expects(:write_crontab).returns(true)
      assert @command.run
    end
  end

  context "A command line update" do
    setup do
      File.expects(:exists?).with('config/schedule.rb').returns(true)
      @command = Whenever::CommandLine.new(:update => true, :identifier => 'My identifier')
      @task = "#{two_hours} /my/command"
      Whenever.expects(:cron).returns(@task)
    end

    should "add the cron to the end of the file if there is no existing identifier block" do
      existing = '# Existing crontab'
      @command.expects(:read_crontab).at_least_once.returns(existing)

      new_cron = <<-EXPECTED
#{existing}

# Begin Whenever generated tasks for: My identifier
#{@task}
# End Whenever generated tasks for: My identifier
EXPECTED

      assert_equal new_cron, @command.send(:updated_crontab)

      @command.expects(:write_crontab).with(new_cron).returns(true)
      assert @command.run
    end

    should "replace an existing block if the identifier matches" do
      existing = <<-EXISTING_CRON
# Something

# Begin Whenever generated tasks for: My identifier
My whenever job that was already here
# End Whenever generated tasks for: My identifier

# Begin Whenever generated tasks for: Other identifier
This shouldn't get replaced
# End Whenever generated tasks for: Other identifier
EXISTING_CRON

      new_cron = <<-NEW_CRON
# Something

# Begin Whenever generated tasks for: My identifier
#{@task}
# End Whenever generated tasks for: My identifier

# Begin Whenever generated tasks for: Other identifier
This shouldn't get replaced
# End Whenever generated tasks for: Other identifier
NEW_CRON

      @command.expects(:read_crontab).at_least_once.returns(existing)
      assert_equal new_cron, @command.send(:updated_crontab)

      @command.expects(:write_crontab).with(new_cron).returns(true)
      assert @command.run
    end
  end

  context "A command line update that contains backslashes" do
    setup do
      @existing = <<-EXISTING_CRON
# Begin Whenever generated tasks for: My identifier
script/runner -e production 'puts '\\''hello'\\'''
# End Whenever generated tasks for: My identifier
EXISTING_CRON
      File.expects(:exists?).with('config/schedule.rb').returns(true)
      @command = Whenever::CommandLine.new(:update => true, :identifier => 'My identifier')
      @command.expects(:read_crontab).at_least_once.returns(@existing)
      @command.expects(:whenever_cron).returns(@existing)
    end

    should "replace the existing block with the backslashes in tact" do
      assert_equal @existing, @command.send(:updated_crontab)
    end
  end

  context "A command line update with an identifier similar to an existing one in the crontab already" do
    setup do
      @existing = <<-EXISTING_CRON
# Begin Whenever generated tasks for: WheneverExisting
# End Whenever generated tasks for: WheneverExisting
EXISTING_CRON
      @new = <<-NEW_CRON
# Begin Whenever generated tasks for: Whenever
# End Whenever generated tasks for: Whenever
NEW_CRON
      File.expects(:exists?).with('config/schedule.rb').returns(true)
      @command = Whenever::CommandLine.new(:update => true, :identifier => 'Whenever')
      @command.expects(:read_crontab).at_least_once.returns(@existing)
      @command.expects(:whenever_cron).returns(@new)
    end

    should "append the similarly named command" do
      assert_equal @existing + "\n" + @new, @command.send(:updated_crontab)
    end
  end

  context "A command line clear" do
    setup do
      File.expects(:exists?).with('config/schedule.rb').returns(true)
      @command = Whenever::CommandLine.new(:clear => true, :identifier => 'My identifier')
      @task = "#{two_hours} /my/command"
    end

    should "clear an existing block if the identifier matches" do
      existing = <<-EXISTING_CRON
# Something

# Begin Whenever generated tasks for: My identifier
My whenever job that was already here
# End Whenever generated tasks for: My identifier

# Begin Whenever generated tasks for: Other identifier
This shouldn't get replaced
# End Whenever generated tasks for: Other identifier
EXISTING_CRON

      @command.expects(:read_crontab).at_least_once.returns(existing)

      new_cron = <<-NEW_CRON
# Something

# Begin Whenever generated tasks for: Other identifier
This shouldn't get replaced
# End Whenever generated tasks for: Other identifier
NEW_CRON

      assert_equal new_cron, @command.send(:updated_crontab)

      @command.expects(:write_crontab).with(new_cron).returns(true)
      assert @command.run
    end
  end

  context "A command line clear with no schedule file" do
    setup do
      File.expects(:exists?).with('config/schedule.rb').returns(false)
      @command = Whenever::CommandLine.new(:clear => true, :identifier => 'My identifier')
    end

    should "run successfully" do
      @command.expects(:write_crontab).returns(true)
      assert @command.run
    end
  end

  context "A command line update with no identifier" do
    setup do
      File.expects(:exists?).with('config/schedule.rb').returns(true)
      Whenever::CommandLine.any_instance.expects(:default_identifier).returns('DEFAULT')
      @command = Whenever::CommandLine.new(:update => true, :file => @file)
    end

    should "use the default identifier" do
      assert_equal "Whenever generated tasks for: DEFAULT", @command.send(:comment_base)
    end
  end

  context "combined params" do
    setup do
      Whenever::CommandLine.any_instance.expects(:exit)
      Whenever::CommandLine.any_instance.expects(:warn)
      File.expects(:exists?).with('config/schedule.rb').returns(true)
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

  context "A runner where the environment is overridden using the :set option" do
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
      assert_match two_hours + %( cd /my/path && script/runner -e serious 'blahblah'), @output
    end
  end

  context "A runner where the environment and path are overridden using the :set option" do
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
      assert_match two_hours + %( cd /serious/path && script/runner -e serious 'blahblah'), @output
    end
  end

  context "A runner where the environment and path are overridden using the :set option with spaces in the string" do
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
      assert_match two_hours + %( cd /serious/path && script/runner -e serious 'blahblah'), @output
    end
  end

  context "A runner where the environment is overridden using the :set option but no value is given" do
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
      assert_match two_hours + %( cd /silly/path && script/runner -e silly 'blahblah'), @output
    end
  end

  context "prepare-ing the output" do
    setup do
      File.expects(:exists?).with('config/schedule.rb').returns(true)
    end

    should "not trim off the top lines of the file" do
      @command = Whenever::CommandLine.new(:update => true, :identifier => 'My identifier', :cut => 0)
      existing = <<-EXISTING_CRON
# Useless Comments
# at the top of the file

# Begin Whenever generated tasks for: My identifier
My whenever job that was already here
# End Whenever generated tasks for: My identifier
EXISTING_CRON

      assert_equal existing, @command.send(:prepare, existing)
    end

    should "trim off the top lines of the file" do
      @command = Whenever::CommandLine.new(:update => true, :identifier => 'My identifier', :cut => '3')
      existing = <<-EXISTING_CRON
# Useless Comments
# at the top of the file

# Begin Whenever generated tasks for: My identifier
My whenever job that was already here
# End Whenever generated tasks for: My identifier
EXISTING_CRON

      new_cron = <<-NEW_CRON
# Begin Whenever generated tasks for: My identifier
My whenever job that was already here
# End Whenever generated tasks for: My identifier
NEW_CRON

      assert_equal new_cron, @command.send(:prepare, existing)
    end

    should "preserve terminating newlines in files" do
      @command = Whenever::CommandLine.new(:update => true, :identifier => 'My identifier')
      existing = <<-EXISTING_CRON
# Begin Whenever generated tasks for: My identifier
My whenever job that was already here
# End Whenever generated tasks for: My identifier

# A non-Whenever task
My non-whenever job that was already here
EXISTING_CRON

      assert_equal existing, @command.send(:prepare, existing)
    end
  end

end
