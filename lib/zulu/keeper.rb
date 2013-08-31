module Zulu
  class Keeper
    include Celluloid::IO
    include Celluloid::Logger
    
    def tick(now=Time.now)
      debug "Looking for topics at: #{now} (#{now.to_i})"
      count = 0
      Topic.happening(now).each do |topic_id|
        topic = Topic.new(id: topic_id)
        debug "Found topic: #{topic_id}"
        distribution = TopicDistribution.new(id: topic_id, now: now)
        distribution.save
        topic.reset_next(now)
        count += 1
      end
      debug "Finished tick: (#{Time.now - now} seconds for #{count} topics)"
    end
    
    def start
      every(Zulu.options[:interval]) { tick }
    end
  end
end