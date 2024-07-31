require 'test_helper'

class OutputJobsWithSequenceTest < Whenever::TestCase
  test "defined jobs with a sequence argument specified per-job" do
    output = Whenever.cron \
    <<-file
      every 2.hours do
        command "blahblah", sequence: 'backups'
        command "foofoo", sequence: 'backups'
        command "barbar"
      end
    file

    output_without_empty_line = lines_without_empty_line(output.lines)
    assert_equal two_hours + " /bin/bash -l -c 'blahblah' && /bin/bash -l -c 'foofoo'", output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'barbar'", output_without_empty_line.shift
  end

  test "defined jobs with a sequence argument specified on the group" do
    output = Whenever.cron \
    <<-file
      every 2.hours, sequence: 'backups' do
        command "blahblah"
        command "foofoo"
      end
    file

    output_without_empty_line = lines_without_empty_line(output.lines)
    assert_equal two_hours + " /bin/bash -l -c 'blahblah' && /bin/bash -l -c 'foofoo'", output_without_empty_line.shift
  end

  test "defined jobs with a sequences specified on the group and jobs" do
    output = Whenever.cron \
    <<-file
      every 2.hours, sequence: 'backups' do
        command "blahblah"
        command "barbar", sequence: nil
        command "foofoo"
        command "bazbaz", sequence: 'bees'
        command "buzzbuzz", sequence: 'bees'
      end
    file

    output_without_empty_line = lines_without_empty_line(output.lines)
    assert_equal two_hours + " /bin/bash -l -c 'blahblah' && /bin/bash -l -c 'foofoo'", output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'barbar'", output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'bazbaz' && /bin/bash -l -c 'buzzbuzz'", output_without_empty_line.shift
  end

  test "defined jobs with a multiple groups with sequences specified on the group and jobs" do
    output = Whenever.cron \
    <<-file
      every 2.hours, sequence: 'backups' do
        command "blahblah"
        command "barbar", sequence: nil
        command "bazbaz", sequence: 'bees'
      end

      every 2.hours, sequence: 'backups' do
        command "foofoo"
        command "buzzbuzz", sequence: 'bees'
      end
    file

    output_without_empty_line = lines_without_empty_line(output.lines)
    assert_equal two_hours + " /bin/bash -l -c 'blahblah' && /bin/bash -l -c 'foofoo'", output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'barbar'", output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'bazbaz' && /bin/bash -l -c 'buzzbuzz'", output_without_empty_line.shift
  end

  test "defined jobs with a multiple groups with sequences specified on the group and jobs" do
    output = Whenever.cron \
    <<-file
      every 2.hours, sequence: 'backups' do
        command "blahblah"
        command "barbar", sequence: nil
        command "bazbaz", sequence: 'bees'
      end

      every 3.hours, sequence: 'backups' do
        command "foofoo"
        command "buzzbuzz", sequence: 'bees'
      end
    file

    output_without_empty_line = lines_without_empty_line(output.lines)
    assert_equal two_hours + " /bin/bash -l -c 'blahblah'", output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'barbar'", output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'bazbaz'", output_without_empty_line.shift
    assert_equal three_hours + " /bin/bash -l -c 'foofoo'", output_without_empty_line.shift
    assert_equal three_hours + " /bin/bash -l -c 'buzzbuzz'", output_without_empty_line.shift
  end

  test "defined jobs with a multiple groups with sequences specified on the group and jobs" do
    assert_raises ArgumentError do
      Whenever.cron \
      <<-file
        every 2.hours, sequence: 'backups' do
          command "blahblah", at: 1
          command "barbar", at: 2
        end
      file
    end
  end

  def three_hours
    "0 0,3,6,9,12,15,18,21 * * *"
  end
end

class OutputJobsWithSequentialTest < Whenever::TestCase
  test "defined jobs with a sequential argument" do
    output = Whenever.cron \
    <<-file
      every 2.hours, sequential: true do
        command "blahblah"
        command "foofoo"
      end
    file

    output_without_empty_line = lines_without_empty_line(output.lines)
    assert_equal two_hours + " /bin/bash -l -c 'blahblah' && /bin/bash -l -c 'foofoo'", output_without_empty_line.shift
  end

  test "defined jobs with a sequential argument" do
    output = Whenever.cron \
    <<-file
      every 2.hours, sequential: true do
        command "blahblah"
        command "foofoo", sequence: false
      end
    file

    output_without_empty_line = lines_without_empty_line(output.lines)
    assert_equal two_hours + " /bin/bash -l -c 'blahblah'", output_without_empty_line.shift
    assert_equal two_hours + " /bin/bash -l -c 'foofoo'", output_without_empty_line.shift
  end
end
