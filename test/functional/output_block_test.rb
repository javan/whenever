require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class BlockTest < Test::Unit::TestCase

  context "With a block configuration" do

    context "weekday at a (single) given time" do
      setup do
        @output = Whenever.cron({}) do
          set :job_template, nil
          every "weekday", :at => '5:02am' do
            command "blahblah"
          end
        end
      end
      
      should "output the command using that time" do
        assert_match '2 5 * * 1-5 blahblah', @output
      end
    end

    context "A plain command with the job template set to nil" do
      setup do
        @output = Whenever.cron({}) do
          set :job_template, nil
          every :day do
            command "blahblah"
          end
        end
      end

      should "output the command" do
        assert_match '0 0 * * * blahblah', @output
      end
    end

    context "A defined job with a :task" do
      setup do
        @output = Whenever.cron({}) do
          set :job_template, nil
          job_type :some_job, "before :task after"
          every 2.hours do
            some_job "during"
          end
        end
      end

      should "output the defined job with the task" do
        assert_match /^.+ .+ .+ .+ before during after$/, @output
      end
    end
  end
end
