require 'test_helper'

class RandomOffsetTest < Whenever::TestCase
  should "generate a random sleep using bash" do
    assert_equal 'sleep $(expr $RANDOM % 9)', Whenever::RandomOffset.sleep_expression(4)
  end

  should "handle large input" do
    assert_equal 'sleep $(expr ($RANDOM * 6) % 172801)', Whenever::RandomOffset.sleep_expression(1.day)
  end

end
