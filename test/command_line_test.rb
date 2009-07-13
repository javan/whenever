require File.expand_path(File.dirname(__FILE__) + "/test_helper")

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

      @command.expects(:read_crontab).at_least_once.returns(existing)
      
      new_cron = <<-NEW_CRON
# Something

# Begin Whenever generated tasks for: My identifier
#{@task}
# End Whenever generated tasks for: My identifier

# Begin Whenever generated tasks for: Other identifier
This shouldn't get replaced
# End Whenever generated tasks for: Other identifier
NEW_CRON
      
      assert_equal new_cron, @command.send(:updated_crontab)
      
      @command.expects(:write_crontab).with(new_cron).returns(true)
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
  
end