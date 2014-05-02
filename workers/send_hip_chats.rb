require 'iron_mq'

class SendHipChats
  attr_reader :iron_mq_client, :queue
  def initialize(options={})
    @iron_mq_client = IronMQ::Client.new(options['iron_mq'])
    @queue = @iron_mq_client.queue(options['iron_mq']['queue_name'])    
  end
  
  def execute
    
  end
end