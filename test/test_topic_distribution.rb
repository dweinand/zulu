require 'minitest_helper'

class TestTopicDistribution < MiniTest::Test
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
  
  def time_now
    Time.new(2013,8,1)
  end
  
  def distribution_options
    {id: topic_id, now: time_now}
  end
  
  def topic_distribution
    TopicDistribution.new(distribution_options)
  end
  
  def test_it_pops_the_next_distribution
    distribution = topic_distribution
    distribution.save
    assert_equal distribution, TopicDistribution.pop
  end
  
  def test_it_accepts_timeout_for_pop
    mock = MiniTest::Mock.new
    mock.expect(:brpop, nil, [TopicDistribution::LIST, timeout: 5])
    Zulu.stub(:redis, mock) do
      TopicDistribution.pop(5)
    end
    mock.verify
  end
  
  def test_it_proxies_topic
    assert_equal Topic.new(id: topic_id), topic_distribution.topic
  end
  
  def test_it_returns_subscriptions_for_topic
    topic = Topic.new(id: topic_id)
    topic.subscribe subscription_id
    assert_includes topic_distribution.subscriptions,
                    Subscription.new(id: subscription_id)
  end
  
  def test_it_reconstructs_options
    assert_equal distribution_options, topic_distribution.to_hash
  end
  
  def test_it_converts_options_to_json
    assert_equal Oj.dump(distribution_options), topic_distribution.to_json
  end
  
  def test_it_adds_self_to_queue_on_save
    distribution = topic_distribution
    distribution.save
    assert_equal distribution.to_json, Zulu.redis.rpop(TopicDistribution::LIST)
  end
  
  def test_it_posts_to_subscription_callback
    distribution = topic_distribution
    subscription = MiniTest::Mock.new
    subscription.expect(:callback, 'www.example.com')
    Http.stub(:post, true) do
      distribution.stub(:subscriptions, [subscription]) do
        distribution.process
      end
    end
    subscription.verify
  end
end