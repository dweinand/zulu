require 'minitest_helper'

class TestSubscriptionRequestProcessor < MiniTest::Test
  include Zulu
  
  def teardown
    Zulu.redis.flushall
  end
  
  def test_it_processes_request
    processor = SubscriptionRequestProcessor.new
    
    request_mock = MiniTest::Mock.new
    request_mock.expect(:process, true)
    
    SubscriptionRequest.stub(:pop, request_mock) do
      processor.stub(:reprocess, true) do
        processor.process
      end
    end
    
    request_mock.verify
  end
end