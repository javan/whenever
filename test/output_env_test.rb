require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class OutputEnvTest < Test::Unit::TestCase

  context "The output from Whenever with environment variables set" do
    setup do
      @output = Whenever.cron \
      <<-file
        env :MYVAR, 'blah'
        env 'MAILTO', "someone@example.com"
      file
    end

    should "output MYVAR environment variable" do
      assert_match "MYVAR=blah", @output
    end
  
    should "output MAILTO environment variable" do
      assert_match "MAILTO=someone@example.com", @output
    end
  end
  
  context "No PATH environment variable set" do
    setup do
      Whenever::JobList.any_instance.expects(:read_path).at_least_once.returns('/usr/local/bin')
      @output = Whenever.cron ""
    end
    
    should "add a PATH variable based on the user's PATH" do
      assert_match "PATH=/usr/local/bin", @output
    end
  end
  
  context "A PATH environment variable set" do
    setup do
      Whenever::JobList.stubs(:read_path).returns('/usr/local/bin')
      @output = Whenever.cron "env :PATH, '/my/path'"
    end
    
    should "use that path and the user's PATH" do
      assert_match "PATH=/my/path", @output
      assert_no_match /local/, @output
    end
  end
  
  context "No PATH set and instructed not to automatically load the user's path" do
    setup do
      @output = Whenever.cron "set :set_path_automatically, false"
    end
    
    should "not have a PATH set" do
      assert_no_match /PATH/, @output
    end
  end

end