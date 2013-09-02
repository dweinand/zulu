module Zulu
  class TopicDistribution
    LIST = "topic_distributions".freeze
    
    def self.push(distribution)
      Zulu.redis.lpush(LIST, distribution.to_json)
    end
    
    def self.pop(timeout=nil)
      _, options = Zulu.redis.brpop(LIST, timeout: timeout)
      options and new(Oj.load(options))
    end
    
    def initialize(options={})
      @id  = options[:id]
      @now = options[:now]
    end
    
    def now
      @now
    end
    
    def topic
      @topic ||= Topic.new(id: @id)
    end
    
    def subscriptions
      topic.subscriptions.map {|sid| Subscription.new(id: sid) }
    end
    
    def ==(other)
      to_hash == other.to_hash
    end
    
    def to_hash
      {id: @id, now: @now}
    end
    
    def to_json
      Oj.dump(to_hash)
    end
    
    def save
      self.class.push(self)
    end
    
    def process
      subscriptions.each do |subscription|
        Http.post(subscription.callback, form: {now: now})
      end
    end
    
  end
end