require 'minitest_helper'

class TestKeeper < MiniTest::Test
  include Zulu
  
  def teardown
    Zulu.redis.flushall
  end
  
  def topic_id
    '5906891b49b573503fcdcce058f1ef5d'
  end
  
  def topic_cron
    '*/15 * * * *'
  end
  
  def topic_options_without_id
    {topic: topic_cron}
  end
  
  def test_it_resets_next_on_tick
    topic = Topic.new(topic_options_without_id)
    now = Time.new(2013,8,1)
    Time.stub(:now, now) do
      topic.save
    end
    keeper = Keeper.new
    keeper.tick now + 15 * 60
    assert_equal (now + 30 * 60).to_i, Zulu.redis.zscore(Topic::UPCOMING_KEY, topic_id)
  end
end