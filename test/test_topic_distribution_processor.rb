require 'minitest_helper'

class TestTopicDistributionProcessor < MiniTest::Test
  include Zulu
  
  def teardown
    Zulu.redis.flushall
  end
  
  def test_it_processes_request
    processor = TopicDistributionProcessor.new
    
    distribution = MiniTest::Mock.new
    distribution.expect(:process, true)
    
    TopicDistribution.stub(:pop, distribution) do
      processor.stub(:reprocess, true) do
        processor.process
      end
    end
    
    distribution.verify
  end
end