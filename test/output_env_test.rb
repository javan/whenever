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

end