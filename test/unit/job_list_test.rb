require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class JobListTest < Test::Unit::TestCase
  
  context "Job List" do
    should "let the schedule file configure custom weekdays & weekends" do
      Whenever::JobList.new("").set_work_week("1-2", "3-4")
      
      assert_equal "1-2", Whenever::Output::Cron.weekdays
      assert_equal "3-4", Whenever::Output::Cron.weekend
      
      set_default_work_week
    end

  end
  
end
