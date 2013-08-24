module Zulu
  class SubscriptionRequest
    LIST = "subscription_requests".freeze
    
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
    
  end
end