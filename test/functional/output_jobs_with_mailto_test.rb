require 'test_helper'

class OutputJobsWithMailtoTest < Whenever::TestCase
  test "defined job with a mailto argument" do
    output = Whenever.cron \
    <<-file
      every 2.hours do
        command "blahblah", mailto: 'someone@example.com'
      end
    file

    output_without_empty_line = lines_without_empty_line(output.lines)

    assert_equal 'MAILTO=someone@example.com', output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah'", output_without_empty_line.shift
  end

  test "defined job with every method's block and a mailto argument" do
    output = Whenever.cron \
    <<-file
      every 2.hours, mailto: 'someone@example.com' do
        command "blahblah"
      end
    file

    output_without_empty_line = lines_without_empty_line(output.lines)

    assert_equal 'MAILTO=someone@example.com', output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah'", output_without_empty_line.shift
  end

  test "defined job which overrided mailto argument in the block" do
    output = Whenever.cron \
    <<-file
      every 2.hours, mailto: 'of_the_block@example.com' do
        command "blahblah", mailto: 'overrided_in_the_block@example.com'
      end
    file

    output_without_empty_line = lines_without_empty_line(output.lines)

    assert_equal 'MAILTO=overrided_in_the_block@example.com', output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah'", output_without_empty_line.shift
  end

  test "defined some jobs with various mailto argument" do
    output = Whenever.cron \
    <<-file
      every 2.hours do
        command "blahblah"
      end

      every 2.hours, mailto: 'john@example.com' do
        command "blahblah_of_john"
        command "blahblah2_of_john"
      end

      every 2.hours, mailto: 'sarah@example.com' do
        command "blahblah_of_sarah"
      end

      every 2.hours do
        command "blahblah_of_martin", mailto: 'martin@example.com'
        command "blahblah2_of_sarah", mailto: 'sarah@example.com'
      end

      every 2.hours do
        command "blahblah2"
      end
    file

    output_without_empty_line = lines_without_empty_line(output.lines)

    assert_equal two_hours + " /bin/bash -l -c 'blahblah'", output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah2'", output_without_empty_line.shift

    assert_equal 'MAILTO=john@example.com', output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah_of_john'", output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah2_of_john'", output_without_empty_line.shift

    assert_equal 'MAILTO=sarah@example.com', output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah_of_sarah'", output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah2_of_sarah'", output_without_empty_line.shift

    assert_equal 'MAILTO=martin@example.com', output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah_of_martin'", output_without_empty_line.shift
  end

  test "defined some jobs with no mailto argument jobs and mailto argument jobs(no mailto jobs should be first line of cron output" do
    output = Whenever.cron \
    <<-file
      every 2.hours, mailto: 'john@example.com' do
        command "blahblah_of_john"
        command "blahblah2_of_john"
      end

      every 2.hours do
        command "blahblah"
      end
    file

    output_without_empty_line = lines_without_empty_line(output.lines)

    assert_equal two_hours + " /bin/bash -l -c 'blahblah'", output_without_empty_line.shift

    assert_equal 'MAILTO=john@example.com', output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah_of_john'", output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah2_of_john'", output_without_empty_line.shift
  end

  test "defined some jobs with environment mailto define and various mailto argument" do
    output = Whenever.cron \
    <<-file
      env 'MAILTO', 'default@example.com'

      every 2.hours do
        command "blahblah"
      end

      every 2.hours, mailto: 'sarah@example.com' do
        command "blahblah_by_sarah"
      end

      every 2.hours do
        command "blahblah_by_john", mailto: 'john@example.com'
      end

      every 2.hours do
        command "blahblah2"
      end
    file

    output_without_empty_line = lines_without_empty_line(output.lines)

    assert_equal 'MAILTO=default@example.com', output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah'", output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah2'", output_without_empty_line.shift

    assert_equal 'MAILTO=sarah@example.com', output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah_by_sarah'", output_without_empty_line.shift

    assert_equal 'MAILTO=john@example.com', output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah_by_john'", output_without_empty_line.shift
  end
end

class OutputJobsWithMailtoForRolesTest < Whenever::TestCase
  test "one role requested and specified on the job with mailto argument" do
    output = Whenever.cron roles: [:role1], :string => \
    <<-file
      env 'MAILTO', 'default@example.com'

      every 2.hours, :roles => [:role1] do
        command "blahblah"
      end

      every 2.hours, mailto: 'sarah@example.com', :roles => [:role2] do
        command "blahblah_by_sarah"
      end
    file

    output_without_empty_line = lines_without_empty_line(output.lines)

    assert_equal 'MAILTO=default@example.com', output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'blahblah'", output_without_empty_line.shift
    assert_nil output_without_empty_line.shift
  end
end
