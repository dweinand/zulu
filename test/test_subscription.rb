require 'minitest_helper'

class TestSubscription < MiniTest::Test
  include Zulu
  
  def teardown
    Zulu.redis.flushall
  end
  
  def subscription_id
    '3a2d38ef403d8f494988a9e1513e7ce0'
  end
  
  def subscription_callback
    'http://www.example.org/callback'
  end
  
  def subscription_options_without_id
    {
      topic:    '*/15 * * * *',
      callback: subscription_callback
    }
  end
  
  def test_it_generates_an_id_for_topic_and_callback
    subscription = Subscription.new(subscription_options_without_id)
    assert_equal subscription_id, subscription.id
  end
  
  def test_it_stores_callback_on_save
    subscription = Subscription.new(subscription_options_without_id)
    subscription.save
    callback = Zulu.redis.get "#{Subscription::KEY_PREFIX}:#{subscription_id}:callback"
    assert_equal subscription_callback, callback
  end
  
  def test_it_saves_topic_on_save
    subscription = Subscription.new(subscription_options_without_id)
    mock_topic = MiniTest::Mock.new
    metaclass = class << mock_topic; self; end
    metaclass.send(:define_method, :subscribe) do |_|
      true
    end
    mock_topic.expect(:save, true)
    subscription.stub(:topic, mock_topic) do
      subscription.save
    end
    mock_topic.verify
  end
  
  def test_it_subscribes_to_topic_on_save
    subscription = Subscription.new(subscription_options_without_id)
    mock_topic = MiniTest::Mock.new
    metaclass = class << mock_topic; self; end
    metaclass.send(:define_method, :save) do
      true
    end
    mock_topic.expect(:subscribe, true, [subscription_id])
    subscription.stub(:topic, mock_topic) do
      subscription.save
    end
    mock_topic.verify
  end
  
  def test_it_retrieves_callback_for_id
    Subscription.new(subscription_options_without_id).save
    callback = Subscription.new(id: subscription_id).callback
    assert_equal subscription_callback, callback
  end
  
  def test_it_removes_callback_on_destroy
    subscription = Subscription.new(subscription_options_without_id)
    subscription.save
    subscription.destroy
    assert_nil Zulu.redis.get "#{Subscription::KEY_PREFIX}:#{subscription_id}:callback"
  end
  
  def test_it_unsubscribes_to_topic_on_destroy
    subscription = Subscription.new(subscription_options_without_id)
    subscription.save
    mock_topic = MiniTest::Mock.new
    mock_topic.expect(:unsubscribe, true, [subscription_id])
    subscription.stub(:topic, mock_topic) do
      subscription.destroy
    end
    mock_topic.verify
  end
  
end