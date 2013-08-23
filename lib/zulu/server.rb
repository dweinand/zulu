require 'sinatra/base'

module Zulu
  class Server < Sinatra::Base
    CONTENT_TYPES = ['application/x-www-form-urlencoded']
    
    post '/' do
      if valid_content_type?
        process_subscription
      else
        status 406
      end
    end
    
    def process_subscription
      status 202
    end
    
    def valid_content_type?
      CONTENT_TYPES.include?(request.content_type)
    end
  end
end