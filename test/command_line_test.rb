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
      output = <<-expected
      # Begin Whenever generated tasks for: My identifier
      #{@task}
      # End Whenever generated tasks for: My identifier
      expected
      
      assert_equal unindent(output).chomp, @command.send(:whenever_cron).chomp
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
      
      new_cron = <<-expected
      #{existing}
      
      # Begin Whenever generated tasks for: My identifier
      #{@task}
      # End Whenever generated tasks for: My identifier
      expected
      
      assert_equal unindent(new_cron).chomp, @command.send(:updated_crontab).chomp
      
      @command.expects(:write_crontab).with(unindent(new_cron)).returns(true)
      assert @command.run
    end
    
    should "replace an existing block if the identifier matches" do
      existing = <<-existing
      # Something
      
      # Begin Whenever generated tasks for: My identifier
      My whenever job that was already here
      # End Whenever generated tasks for: My identifier
      
      # Begin Whenever generated tasks for: Other identifier
      This shouldn't get replaced
      # End Whenever generated tasks for: Other identifier
      existing
      @command.expects(:read_crontab).at_least_once.returns(unindent(existing))
      
      new_cron = <<-new_cron
      # Something
      
      # Begin Whenever generated tasks for: My identifier
      #{@task}
      # End Whenever generated tasks for: My identifier
      
      # Begin Whenever generated tasks for: Other identifier
      This shouldn't get replaced
      # End Whenever generated tasks for: Other identifier
      new_cron
      
      assert_equal unindent(new_cron).chomp, @command.send(:updated_crontab).chomp
      
      @command.expects(:write_crontab).with(unindent(new_cron)).returns(true)
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
  
private
  
  def unindent(string)
    indentation = string[/\A\s*/]
    string.strip.gsub(/^#{indentation}/, "")
  end
  
end