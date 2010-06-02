require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class OutputUserDefinedTest < Test::Unit::TestCase
  
  context "A custom job type" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :path, '/my/path'
        job_type :simple_job do |job|
          job.command = "hello"
        end
        every 2.hours do
          simple_job "blahblah"
        end
      file
    end
    
    should "output the command using simple_job" do
      assert_match two_hours + ' cd /my/path && hello -e production "blahblah"', @output
    end
  end
  
  context "A custom job type which does not quote the task" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :path, '/my/path'
        job_type :simple_job do |job|
          job.command = "hello"
          job.settings = { :quote_task => false }
        end
        every 2.hours do
          simple_job "blahblah"
        end
      file
    end
    
    should "output the command using simple_job and not quote the task" do
      assert_match two_hours + ' cd /my/path && hello -e production blahblah', @output
    end
  end
  
  context "A custom job type with no path" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :path, '/my/path'
        job_type :simple_job do |job|
          job.command = "hello"
          job.settings = { :path => false }
        end
        every 2.hours do
          simple_job "blahblah"
        end
      file
    end
    
    should "output the command using simple_job without changing directory first" do
      assert_match two_hours + ' hello -e production "blahblah"', @output
    end
  end
  
  context "A custom job type with path" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :path, '/my/path'
        job_type :simple_job do |job|
          job.command = "hello"
          job.settings = { :path => "/path/to/app" }
        end
        every 2.hours do
          simple_job "blahblah"
        end
      file
    end
    
    should "output the command using simple_job and a custom path" do
      assert_match two_hours + ' cd /path/to/app && hello -e production "blahblah"', @output
    end
  end
  
  context "A custom job which uses bunder" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :path, '/my/path'
        job_type :simple_job do |job|
          job.command = "hello"
          job.settings = { :use_bundler => true }
        end
        every 2.hours do
          simple_job "blahblah"
        end
      file
    end
    
    should "output the command using simple_job with bundler" do
      assert_match two_hours + ' cd /my/path && bundle exec hello -e production "blahblah"', @output
    end
  end
  
  context "A custom job which uses bunder and a custom path" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :path, '/my/path'
        job_type :simple_job do |job|
          job.command = "hello"
          job.settings = { :use_bundler => true, :path => "/path/to/app" }
        end
        every 2.hours do
          simple_job "blahblah"
        end
      file
    end
    
    should "output the command using simple_job with bundler and a custom path" do
      assert_match two_hours + ' cd /path/to/app && bundle exec hello -e production "blahblah"', @output
    end
  end
  
  context "A custom job with settings set individually" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :path, '/my/path'
        job_type :simple_job do |job|
          job.command = "hello"
          job.settings[:use_bundler] = true
          job.settings[:path] = "/path/to/app"
        end
        every 2.hours do
          simple_job "blahblah"
        end
      file
    end
    
    should "output the command with all the settings as expected" do
      assert_match two_hours + ' cd /path/to/app && bundle exec hello -e production "blahblah"', @output
    end
  end
  
  context "A custom job which doesn't use an environment" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :path, '/my/path'
        job_type :simple_job do |job|
          job.command = "hello"
          job.settings = { :environment => false }
        end
        every 2.hours do
          simple_job "blahblah"
        end
      file
    end
    
    should "output the command using simple_job without environment" do
      assert_match two_hours + ' cd /my/path && hello "blahblah"', @output
    end
  end
  
  context "A custom job that overrides the path set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :path, '/my/path'
        job_type :simple_job do |job|
          job.command = "hello"
        end
        every 2.hours do
          simple_job "blahblah", :path => '/some/other/path'
        end
      file
    end
    
    should "output the runner using that path" do
      assert_match two_hours + ' cd /some/other/path && hello -e production "blahblah"', @output
    end
  end
  
  context "A custom job that overrides the path set from the job_type definition" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :path, '/my/path'
        job_type :simple_job do |job|
          job.command = "hello"
          job.settings = { :path => "/some/other/path" }
        end
        every 2.hours do
          simple_job "blahblah"
        end
      file
    end
    
    should "output the runner using that path" do
      assert_match two_hours + ' cd /some/other/path && hello -e production "blahblah"', @output
    end
  end
  
  context "A custom job with an environment set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :environment, :silly
        set :path, '/my/path'
        job_type :simple_job do |job|
          job.command = "hello"
        end
        every 2.hours do
          simple_job "blahblah"
        end
      file
    end
    
    should "output the runner using that environment" do
      assert_match two_hours + ' cd /my/path && hello -e silly "blahblah"', @output
    end
  end
  
  context "A custom job that overrides the environment set" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :environment, :silly
        set :path, '/my/path'
        job_type :simple_job do |job|
          job.command = "hello"
        end
        every 2.hours do
          simple_job "blahblah", :environment => :serious
        end
      file
    end
    
    should "output the runner using that environment" do
      assert_match two_hours + ' cd /my/path && hello -e serious "blahblah"', @output
    end
  end
  
  context "A custom job that overrides the environment set in the job_type definition" do
    setup do
      @output = Whenever.cron \
      <<-file
        set :environment, :silly
        set :path, '/my/path'
        job_type :simple_job do |job|
          job.command = "hello"
          job.settings = { :environment => :serious }
        end
        every 2.hours do
          simple_job "blahblah"
        end
      file
    end
    
    should "output the runner using that environment" do
      assert_match two_hours + ' cd /my/path && hello -e serious "blahblah"', @output
    end
  end
  
  context "A custom job where the environment is overridden using the :set option" do
    setup do
      @output = Whenever.cron :set => 'environment=serious', :string => \
      <<-file
        set :environment, :silly
        set :path, '/my/path'
        job_type :simple_job do |job|
          job.command = "hello"
        end
        every 2.hours do
          simple_job "blahblah"
        end
      file
    end
    
    should "output the runner using the override environment" do
      assert_match two_hours + ' cd /my/path && hello -e serious "blahblah"', @output
    end
  end
  
  context "A custom job where the environment and path are overridden using the :set option" do
    setup do
      @output = Whenever.cron :set => 'environment=serious&path=/serious/path', :string => \
      <<-file
        set :environment, :silly
        set :path, '/silly/path'
        job_type :simple_job do |job|
          job.command = "hello"
        end
        every 2.hours do
          simple_job "blahblah"
        end
      file
    end
    
    should "output the runner using the overridden path and environment" do
      assert_match two_hours + ' cd /serious/path && hello -e serious "blahblah"', @output
    end
  end
  
  
  
end
