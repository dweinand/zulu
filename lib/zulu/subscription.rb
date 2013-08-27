require "digest/md5"

module Zulu
  class Subscription
    
    KEY_PREFIX = "subscription".freeze
    
    def initialize(options={})
      @id       = options[:id]
      @topic    = options[:topic]
      @callback = options[:callback]
    end
    
    def id
      @id ||= Digest::MD5.hexdigest [@topic, @callback].join(':')
    end
    
    def callback
      @callback ||= Zulu.redis.get "#{KEY_PREFIX}:#{id}:callback"
    end
    
    def save
      Zulu.redis.set "#{KEY_PREFIX}:#{id}:callback", callback
    end
    
    def destroy
      Zulu.redis.del "#{KEY_PREFIX}:#{id}:callback"
    end
    
  end
end