require 'iron_mq'
require 'hipchat'
class SendHipChats
  attr_reader :iron_mq_client, :queue
  def initialize(options={})
    @iron_mq_client = IronMQ::Client.new(options['iron_mq'])
    @queue = @iron_mq_client.queue(options['iron_mq']['queue_name'])    
  end
  
  
  def send_post(post)
    client = HipChat::Client.new(post['api_token'], api_version: 'v2')
    client[post['room']].send(post['username'], post['text'], notify: true)
  end

  def execute
    messages = self.queue.messages.get(:n=>100)
    messages.each do |message|
      body = message.body
      json = JSON.parse(body)
      message.delete
    end
    
  end
end