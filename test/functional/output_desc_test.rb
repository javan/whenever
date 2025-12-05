require 'test_helper'

class OutputDescTest < Whenever::TestCase
  test "single line description" do
    output = Whenever.cron \
    <<-file
      every "weekday", :desc => "A description" do
        command "blahblah"
      end
    file

    assert_match "# A description\n0 0 * * 1-5 /bin/bash -l -c 'blahblah'\n\n", output
  end

  test "multi line description" do
    output = Whenever.cron \
    <<-file
      every "weekday", :desc => "A description\nhas mulitple lines" do
        command "blahblah"
      end
    file

    assert_match "# A description\n# has mulitple lines\n0 0 * * 1-5 /bin/bash -l -c 'blahblah'\n\n", output
  end
end
