require 'sinatra/base'

module Zulu
  class Server < Sinatra::Base
    CONTENT_TYPES = ['application/x-www-form-urlencoded']
    
    get '/' do
      Time.now.utc.xmlschema
    end
    
    post '/' do
      if valid_content_type?
        process_subscription
      else
        error 406
      end
    end
    
    def process_subscription
      request = SubscriptionRequest.new(params)
      if request.save
        status 202
      else
        error 422, request.error_messages.join("\n")
      end
    end
    
    def valid_content_type?
      CONTENT_TYPES.include?(request.content_type)
    end
  end
end