require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class OutputAtTest < Test::Unit::TestCase
  
  context "weekday at a (single) given time" do
    setup do
      @output = Whenever.cron \
      <<-file
        every "weekday", :at=>'5:02am' do
          command "blahblah"
        end
      file
    end
    
    should "output the runner using that path" do
      assert_match '2 5 * * 1-5 blahblah', @output
    end
  end
  
  context "weekday at a multiple diverse times, via an array" do
    setup do
      @output = Whenever.cron \
      <<-file
        every "weekday", :at=>%w(5:02am 3:52pm) do
          command "blahblah"
        end
      file
    end
    
    should "output the runner using that path" do
      assert_match '2 5 * * 1-5 blahblah', @output
      assert_match '52 15 * * 1-5 blahblah', @output
    end
  end
  
  context "weekday at a multiple diverse times, comma separated" do
    setup do
      @output = Whenever.cron \
      <<-file
        every "weekday", :at=>'5:02am, 3:52pm' do
          command "blahblah"
        end
      file
    end
    
    should "output the runner using that path" do
      assert_match '2 5 * * 1-5 blahblah', @output
      assert_match '52 15 * * 1-5 blahblah', @output
    end
  end
  
  context "weekday at a multiple aligned times" do
    setup do
      @output = Whenever.cron \
      <<-file
        every "weekday", :at=>'5:02am, 3:02pm' do
          command "blahblah"
        end
      file
    end
    
    should "output the runner using that path" do
      assert_match '2 5,15 * * 1-5 blahblah', @output
    end
  end
  
  context "various days at a various aligned times" do
    setup do
      @output = Whenever.cron \
      <<-file
        every "mon,wed,fri", :at=>'5:02am, 3:02pm' do
          command "blahblah"
        end
      file
    end
    
    should "output the runner using that path" do
      assert_match '2 5,15 * * 1,3,5 blahblah', @output
    end
  end
  
end
