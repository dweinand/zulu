require 'minitest_helper'

class TestHttp < MiniTest::Test
  include Zulu
  
  def test_it_returns_response_for_get
    response = Object.new
    Net::HTTP.stub(:get_response, response) do
      assert_equal response, Http.get('http://www.example.com')
    end
  end

  def test_it_returns_response_for_post
    response = Object.new
    Net::HTTP.stub(:post_form, response) do
      assert_equal response, Http.post('http://www.example.com')
    end
  end
  
end