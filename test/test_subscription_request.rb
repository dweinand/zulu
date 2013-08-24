require 'minitest_helper'

class TestSubscriptionRequest < MiniTest::Test
  include Zulu
  
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
  
  def subscribe_request(opts={})
    SubscriptionRequest.new(subscribe_options(opts))
  end
  
  def test_it_is_valid_with_subscribe
    assert subscribe_request.valid?
  end
  
  def test_it_is_valid_with_unsubscribe
    assert subscribe_request('hub.mode' => 'unsubscribe').valid?
  end
  
  def test_it_is_not_valid_with_missing_mode
    deny subscribe_request('hub.mode' => nil).valid?
  end
  
  def test_it_has_error_with_missing_mode
    request = subscribe_request('hub.mode' => nil)
    request.valid?
    assert_includes request.errors, [:mode, 'must be present']
  end
  
  def test_it_is_not_valid_with_wrong_mode
    deny subscribe_request('hub.mode' => 'dance').valid?
  end
  
  def test_it_has_error_with_wrong_mode
    request = subscribe_request('hub.mode' => 'dance')
    request.valid?
    assert_includes request.errors, [:mode, "must be either 'subscribe' or 'unsubscribe'"]
  end
  
  def test_it_is_not_valid_with_missing_topic
    deny subscribe_request('hub.topic' => nil).valid?
  end
  
  def test_it_has_error_with_missing_topic
    request = subscribe_request('hub.topic' => nil)
    request.valid?
    assert_includes request.errors, [:topic, 'must be present']
  end
  
  def test_it_is_not_valid_with_missing_callback
    deny subscribe_request('hub.callback' => nil).valid?
  end
  
  def test_it_has_error_with_missing_callback
    request = subscribe_request('hub.callback' => nil)
    request.valid?
    assert_includes request.errors, [:callback, 'must be present']
  end
  
  def test_it_is_not_valid_with_wrong_callback
    deny subscribe_request('hub.callback' => '!?/#:-)').valid?
  end
  
  def test_it_has_error_with_wrong_callback
    request = subscribe_request('hub.callback' => '!?/#:-)')
    request.valid?
    assert_includes request.errors, [:callback, "must be a valid http url"]
  end
  
  def test_it_contructs_proper_error_messages
    request = subscribe_request('hub.callback' => nil)
    request.valid?
    assert_includes request.error_messages, 'hub.callback must be present'
  end
  
  def test_it_reconstructs_params
    assert_equal subscribe_options, subscribe_request.to_hash
  end
  
  def test_it_converts_params_to_json
    assert_equal Oj.dump(subscribe_options), subscribe_request.to_json
  end
  
  def test_it_adds_self_to_queue_on_save
    request = subscribe_request
    request.save
    assert_equal request.to_json, Zulu.redis.rpop(SubscriptionRequest::LIST)
  end
  
  def test_it_does_not_addsself_to_queue_on_save
    request = subscribe_request('hub.mode' => nil)
    request.save
    assert_nil Zulu.redis.rpop(SubscriptionRequest::LIST)
  end
  
  def test_it_passes_save_when_valid
    request = subscribe_request
    assert request.save
  end
  
  def test_it_fails_save_when_invalid
    request = subscribe_request('hub.mode' => nil)
    deny request.save
  end
  
end