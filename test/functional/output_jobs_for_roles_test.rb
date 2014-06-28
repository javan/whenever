require 'test_helper'

class OutputJobsForRolesTest < Whenever::TestCase
  test "one role requested and specified on the job" do
    output = Whenever.cron :roles => [:role1], :string => \
    <<-file
      every 2.hours, :roles => [:role1] do
        command "blahblah"
      end
    file

    assert_equal two_hours + " /bin/bash -l -c 'blahblah'\n\n", output
  end

  test "one role requested but none specified on the job" do
    output = Whenever.cron :roles => [:role1], :string => \
    <<-file
      every 2.hours do
        command "blahblah"
      end
    file

    # this should output the job because not specifying a role means "all roles"
    assert_equal two_hours + " /bin/bash -l -c 'blahblah'\n\n", output
  end

  test "no roles requested but one specified on the job" do
    output = Whenever.cron \
    <<-file
      every 2.hours, :roles => [:role1] do
        command "blahblah"
      end
    file

    # this should output the job because not requesting roles means "all roles"
    assert_equal two_hours + " /bin/bash -l -c 'blahblah'\n\n", output
  end

  test "a different role requested than the one specified on the job" do
    output = Whenever.cron :roles => [:role1], :string => \
    <<-file
      every 2.hours, :roles => [:role2] do
        command "blahblah"
      end
    file

    assert_equal "", output
  end

  test "with 2 roles requested and a job defined for each" do
    output = Whenever.cron :roles => [:role1, :role2], :string => \
    <<-file
      every 2.hours, :roles => [:role1] do
        command "role1_cmd"
      end

      every :hour, :roles => [:role2] do
        command "role2_cmd"
      end
    file

    assert_match two_hours + " /bin/bash -l -c 'role1_cmd'", output
    assert_match "0 * * * * /bin/bash -l -c 'role2_cmd'", output
  end
end
