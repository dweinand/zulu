require 'minitest_helper'

class TestServer < MiniTest::Test
  include Rack::Test::Methods
  include Zulu
  
  def app
    Server
  end
  
  def subscribe_options(opts={})
    {
      'hub.mode' => 'subscribe',
      'hub.topic' => '*/15 * * * *',
      'hub.callback' => 'http://www.example.org/callback'
    }.merge(opts)
  end
  
  def test_it_renders_current_time_on_get
    now = Time.now.utc
    get '/'
    assert_equal now.xmlschema, last_response.body
  end
  
  def test_it_accepts_subscription_request
    post '/', subscribe_options
    assert_equal 202, last_response.status, last_response.body
  end
  
  def test_it_wont_accept_incorrect_format
    post '/', '', 'CONTENT_TYPE' => 'application/rss+xml'
    assert_equal 406, last_response.status
  end
end