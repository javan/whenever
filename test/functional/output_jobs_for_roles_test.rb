require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class OutputJobsForRolesTest < Test::Unit::TestCase
  context "with one role requested and specified on the job" do
    setup do
      @output = Whenever.cron :roles => [:role1], :string => \
      <<-file
        every 2.hours, :roles => [:role1] do
          command "blahblah"
        end
      file
    end

    should "output the cron job" do
      assert_equal two_hours + " /bin/bash -l -c 'blahblah'\n\n", @output
    end
  end

  context "with one role requested but none specified on the job" do
    setup do
      @output = Whenever.cron :roles => [:role1], :string => \
      <<-file
        every 2.hours do
          command "blahblah"
        end
      file
    end

    # this should output the job because not specifying a role means "all roles"
    should "output the cron job" do
      assert_equal two_hours + " /bin/bash -l -c 'blahblah'\n\n", @output
    end
  end

  context "with no roles requested but one specified on the job" do
    setup do
      @output = Whenever.cron \
      <<-file
        every 2.hours, :roles => [:role1] do
          command "blahblah"
        end
      file
    end

    # this should output the job because not requesting roles means "all roles"
    should "output the cron job" do
      assert_equal two_hours + " /bin/bash -l -c 'blahblah'\n\n", @output
    end
  end

  context "with a different role requested than the one specified on the job" do
    setup do
      @output = Whenever.cron :roles => [:role1], :string => \
      <<-file
        every 2.hours, :roles => [:role2] do
          command "blahblah"
        end
      file
    end

    should "not output the cron job" do
      assert_equal "", @output
    end
  end

  context "with 2 roles requested and a job defined for each" do
    setup do
      @output = Whenever.cron :roles => [:role1, :role2], :string => \
      <<-file
        every 2.hours, :roles => [:role1] do
          command "role1_cmd"
        end

        every :hour, :roles => [:role2] do
          command "role2_cmd"
        end
      file
    end

    should "output both jobs" do
      assert_match two_hours + " /bin/bash -l -c 'role1_cmd'", @output
      assert_match "0 * * * * /bin/bash -l -c 'role2_cmd'", @output
    end
  end
end
