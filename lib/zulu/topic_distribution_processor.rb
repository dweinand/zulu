require "celluloid/io"

module Zulu
  class TopicDistributionProcessor
    include Celluloid::IO
    include Celluloid::Logger
    
    finalizer :shutdown
    
    def initialize
      debug "Distribution Processor starting up"
    end
    
    def process
      debug "Looking for a topic distribution"
      distribution = TopicDistribution.pop(1)
      if distribution
        debug "Distribution found. Processing..."
        distribution.process
      end
      async.reprocess
    end
    
    def reprocess
      debug "Distribution Reprocessing..."
      after(0) { process }
    end
    
    def shutdown
      debug "Distribution Processor shutting down"
    end
  end
end