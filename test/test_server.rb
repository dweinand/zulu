require 'minitest_helper'

class TestServer < MiniTest::Test
  include Rack::Test::Methods
  include Zulu
  
  def app
    Server
  end
  
  def teardown
    Zulu.redis.flushall
  end
  
  def subscribe_options(opts={})
    {
      'hub.mode' => 'subscribe',
      'hub.topic' => '*/15 * * * *',
      'hub.callback' => 'http://www.example.org/callback'
    }.merge(opts)
  end
  
  def test_it_renders_current_time_on_get
    now = Time.now
    Time.stub(:now, now) do
      get '/'
    end
    assert_equal now.utc.xmlschema, last_response.body
  end
  
  def test_it_accepts_subscription_request
    post '/', subscribe_options
    assert_equal 202, last_response.status, last_response.body
  end
  
  def test_it_errors_if_save_fails
    post '/', subscribe_options('hub.mode' => 'dance')
    assert_equal 400, last_response.status, last_response.body
  end
  
  def test_it_displays_errors_if_save_fails
    post '/', subscribe_options('hub.mode' => nil)
    errs = "hub.mode must be present\nhub.mode must be either subscribe or unsubscribe"
    assert_equal errs, last_response.body
  end
  
  def test_it_wont_accept_incorrect_format
    post '/', '', 'CONTENT_TYPE' => 'application/rss+xml'
    assert_equal 406, last_response.status
  end
end