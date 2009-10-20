require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class OutputCommandTest < Test::Unit::TestCase
  
  context "A plain command" do
    setup do
      @output = Whenever.cron \
      <<-file
        every 2.hours do
          command "blahblah"
        end
      file
    end
    
    should "output the command" do
      assert_match /^.+ .+ .+ .+ blahblah$/, @output
    end
  end
  
  context "An every statement with two commands in it" do
    setup do
      @output = Whenever.cron \
      <<-file
        every 1.hour do
          command "first"
          command "second"
        end
      file
    end

    should "output both commands" do
      assert_match "0 * * * * first", @output
      assert_match "0 * * * * second", @output
    end
  end
    
end