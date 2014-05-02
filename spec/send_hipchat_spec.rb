require 'rspec'
require File.expand_path(File.dirname(__FILE__) + '/../workers/send_hip_chats')

describe SendHipChats do
  describe "initializer" do
    before(:each) do
      @options = {
        'iron_mq'=>{'token'=>'some set value', 'project_id'=>'some-24-char-project-id-', 'queue_name'=>'some_test_queue'}
      }
      @send_hip_chats = SendHipChats.new(@options)
    end

    describe "iron_mq_client" do
      
      it "should assign the token" do
        @send_hip_chats.iron_mq_client.token.should == @options['iron_mq']['token']
      end
  
      it "should assign the project_id" do
        @send_hip_chats.iron_mq_client.project_id.should == @options['iron_mq']['project_id']
      end
      
      it "should assign the queue with the provided queue name" do
        @send_hip_chats.queue.name.should == @options['iron_mq']['queue_name']
      end
    end
  end
end