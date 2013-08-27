require "celluloid/io"

module Zulu
  class SubscriptionRequestProcessor
    include Celluloid::IO
    include Celluloid::Logger
    
    finalizer :shutdown
    
    def initialize
      debug "Request Processor starting up"
    end
    
    def process
      debug "Looking for a subscription request"
      request = SubscriptionRequest.pop(1)
      if request
        debug "Request found. Processing..."
        request.process
      end
      async.reprocess
    end
    
    def reprocess
      debug "Reprocessing..."
      after(0) { process }
    end
    
    def shutdown
      debug "Request Processor shutting down"
    end
  end
end