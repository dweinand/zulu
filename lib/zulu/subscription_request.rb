require "addressable/uri"
require "oj"


module Zulu
  class SubscriptionRequest
    LIST = "subscription_requests".freeze
    
    def self.pop(timeout=nil)
      _, params = Zulu.redis.brpop(LIST, timeout: timeout)
      params and new(Oj.load(params))
    end
    
    def initialize(params)
      @mode     = params['hub.mode']
      @topic    = params['hub.topic']
      @callback = params['hub.callback']
    end
    
    def valid?
      @valid ||= begin
        validate_mode
        validate_topic
        validate_callback
        errors.empty?
      end
    end
    
    def errors
      @errors ||= []
    end
    
    def error_messages
      errors.map {|e| "hub.#{e[0]} #{e[1]}" }
    end
    
    def save
      valid? and Zulu.redis.lpush(LIST, to_json)
    end
    
    def to_hash
      [:mode, :topic, :callback].inject({}) do |hash, attr|
        hash["hub.#{attr}"] = instance_variable_get(:"@#{attr}")
        hash
      end
    end
    
    def to_json
      Oj.dump(to_hash)
    end
    
    def ==(other)
      to_hash == other.to_hash
    end
    
    private
    
    def validate_mode
      @mode or errors << [:mode, 'must be present']
      in_list = ['subscribe','unsubscribe'].include?(@mode)
      in_list or errors << [:mode, "must be either 'subscribe' or 'unsubscribe'"]
    end
    
    def validate_topic
      @topic or errors << [:topic, 'must be present']
    end
    
    def validate_callback
      @callback or errors << [:callback, 'must be present']
      uri = Addressable::URI.parse(@callback)
      uri and %w(http https).include? uri.scheme or fail Addressable::URI::InvalidURIError
    rescue Addressable::URI::InvalidURIError
      errors << [:callback, 'must be a valid http url']
    end
    
  end
end