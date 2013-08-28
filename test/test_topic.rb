require 'minitest_helper'

class TestSubscription < MiniTest::Test
  include Zulu
  
  def teardown
    Zulu.redis.flushall
  end
  
  def topic_id
    '5906891b49b573503fcdcce058f1ef5d'
  end
  
  def subscription_id
    '3a2d38ef403d8f494988a9e1513e7ce0'
  end
  
  def topic_cron
    '*/15 * * * *'
  end
  
  def topic_options_without_id
    {topic: topic_cron}
  end
  
  def test_it_generates_an_id_for_topic
    topic = Topic.new(topic_options_without_id)
    assert_equal topic_id, topic.id
  end
  
  def test_it_calculates_next_time
    topic = Topic.new(topic_options_without_id)
    now = Time.new(2013,8,1)
    assert_equal now + 15 * 60, topic.next_time(now)
  end
  
  def test_it_stores_next_time_on_reset
    topic = Topic.new(topic_options_without_id)
    now = Time.new(2013,8,1)
    topic.reset_next(now)
    topic_next = Zulu.redis.zscore Topic::UPCOMING_KEY, topic_id
    assert_equal (now + 15 * 60).to_i, topic_next
  end
  
  def test_it_stores_next_time_on_save
    topic = Topic.new(topic_options_without_id)
    now = Time.new(2013,8,1)
    Time.stub(:now, now) do
      topic.save
    end
    topic_next = Zulu.redis.zscore Topic::UPCOMING_KEY, topic_id
    assert_equal (now + 15 * 60).to_i, topic_next
  end
  
  def test_it_stores_topic_on_save
    topic = Topic.new(topic_options_without_id)
    topic.save
    topic_topic = Zulu.redis.get "#{Topic::KEY_PREFIX}:#{topic_id}"
    assert_equal topic_cron, topic_topic
  end
  
  def test_it_retrieves_topic_for_id
    Topic.new(topic_options_without_id).save
    topic_topic = Topic.new(id: topic_id).topic
    assert_equal topic_cron, topic_topic
  end
  
  def test_it_removes_topic_on_destroy
    topic = Topic.new(topic_options_without_id)
    topic.save
    topic.destroy
    assert_nil Zulu.redis.get "#{Topic::KEY_PREFIX}:#{topic_id}"
  end
  
  def test_it_removes_topic_from_upcoming_on_destroy
    topic = Topic.new(topic_options_without_id)
    topic.save
    topic.destroy
    assert_empty Zulu.redis.zrange Topic::UPCOMING_KEY, 0, -1
  end
  
  def test_it_finds_present_topic_in_happening
    topic = Topic.new(topic_options_without_id)
    now = Time.new(2013,8,1)
    Time.stub(:now, now) do
      topic.save
    end
    assert_includes Topic.happening(now + 15 * 60), topic.id
  end
  
  def test_it_finds_past_topic_in_happening
    topic = Topic.new(topic_options_without_id)
    now = Time.new(2013,8,1)
    Time.stub(:now, now) do
      topic.save
    end
    assert_includes Topic.happening(now + 20 * 60), topic.id
  end
  
  def test_it_does_not_find_future_topic_in_happening
    topic = Topic.new(topic_options_without_id)
    now = Time.new(2013,8,1)
    Time.stub(:now, now) do
      topic.save
    end
    deny_includes Topic.happening(now), topic.id
  end
  
  def test_it_adds_subscription_on_subscribe
    topic = Topic.new(topic_options_without_id)
    topic.subscribe subscription_id
    assert_includes topic.subscriptions, subscription_id
  end
  
  def test_it_increments_subscription_count_on_subscribe
    topic = Topic.new(topic_options_without_id)
    topic.subscribe subscription_id
    assert_equal 1, topic.subscriptions_count
  end
  
  def test_it_removes_subscription_on_unsubscribe
    topic = Topic.new(topic_options_without_id)
    topic.subscribe subscription_id
    topic.unsubscribe subscription_id
    deny_includes topic.subscriptions, subscription_id
  end
  
  def test_it_decrements_subscription_count_on_unsubscribe
    topic = Topic.new(topic_options_without_id)
    topic.subscribe subscription_id
    topic.unsubscribe subscription_id
    assert_equal 0, topic.subscriptions_count
  end
  
  def test_it_destroys_topic_from_upcoming_on_destroy
    topic = Topic.new(topic_options_without_id)
    topic.save
    topic.subscribe subscription_id
    topic.unsubscribe subscription_id
    assert_nil Zulu.redis.get "#{Topic::KEY_PREFIX}:#{topic_id}"
  end

end