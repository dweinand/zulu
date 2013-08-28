require "digest/md5"
require "rufus/sc/cronline"

module Zulu
  class Topic
    
    KEY_PREFIX = "topic".freeze
    UPCOMING_KEY = "#{KEY_PREFIX}:upcoming".freeze
    
    def self.happening(now=Time.now)
      Zulu.redis.zrangebyscore(UPCOMING_KEY, 0, now.to_i)
    end
    
    def initialize(options={})
      @id       = options[:id]
      @topic    = options[:topic]
    end
    
    def id
      @id ||= Digest::MD5.hexdigest @topic
    end
    
    def topic
      @topic ||= Zulu.redis.get "#{KEY_PREFIX}:#{id}"
    end
    
    def subscriptions_count
      Zulu.redis.scard("#{KEY_PREFIX}:#{id}:subscriptions")
    end

    def subscriptions
      Zulu.redis.smembers("#{KEY_PREFIX}:#{id}:subscriptions")
    end
    
    def subscribe(subscription_id)
      Zulu.redis.sadd("#{KEY_PREFIX}:#{id}:subscriptions", subscription_id)
    end
    
    def unsubscribe(subscription_id)
      Zulu.redis.srem("#{KEY_PREFIX}:#{id}:subscriptions", subscription_id)
      destroy if subscriptions_count == 0
    end
    
    def parser
      @parser ||= Rufus::CronLine.new(topic)
    end
    
    def next_time
      parser.next_time(Time.now)
    end
    
    def reset_next
      Zulu.redis.zadd(UPCOMING_KEY, next_time.to_i, id)
    end
    
    def save
      Zulu.redis.multi do
        Zulu.redis.set "#{KEY_PREFIX}:#{id}", topic
        reset_next
      end
    end
    
    def destroy
      Zulu.redis.multi do
        Zulu.redis.del "#{KEY_PREFIX}:#{id}"
        Zulu.redis.zrem(UPCOMING_KEY, id)
      end
    end
  end
end