require 'minitest_helper'

class TestChallenge < MiniTest::Test
  include Zulu
  
  def test_it_returns_24_characters_by_default
    assert_equal 24, Challenge.new.length
  end
  
  def test_it_allows_arbitrary_size
    assert_equal 12, Challenge.new(12).length
  end
  
  def test_it_produces_appropriate_string
    assert_match /[a-zA-Z0-9]/, Challenge.new
  end
  
end