require 'rspec'
require File.expand_path(File.dirname(__FILE__) + '/../workers/send_hip_chats')

describe SendHipChats do
  TESTING_QUEUE_NAME='send_hipchats_testing'
  TESTING_HIPCHAT_ROOM = 'API Testing'
  TESTING_HIPCHAT_USERNAME = 'Testing User'
  def testing_params
    @iron_mq_config ||= JSON.parse(File.read('spec/config/iron_mq.json'))
    {'iron_mq'=>@iron_mq_config.merge('queue_name'=>TESTING_QUEUE_NAME)}
  end;
  
  def hipchat_api_key
    @testing_api_key ||= File.read("spec/config/hipchat.api.key")
  end

  describe "initializer" do
    before(:each) do
      @options = {
        'iron_mq'=>{'token'=>'some set value', 'project_id'=>'some-24-char-project-id-', 'queue_name'=>'some_test_queue', "host"=>"somehostname.com"}
      }
      @worker = SendHipChats.new(@options)
    end

    describe "iron_mq_client" do
      
      it "assigns the token" do
        expect(@worker.iron_mq_client.token).to eq(@options['iron_mq']['token'])
      end
  
      it "assigns the project_id" do
        expect(@worker.iron_mq_client.project_id).to eq(@options['iron_mq']['project_id'])
      end
      
      it "sets the host" do
        expect(@worker.iron_mq_client.host).to eq(@options['iron_mq']['host'])
      end

      it "assigns the queue with the provided queue name" do
        expect(@worker.queue.name).to eq(@options['iron_mq']['queue_name'])
      end
    end
  end
  
  def test_post
    {'text'=>"This is text", 'room'=>TESTING_HIPCHAT_ROOM, 'api_token'=>hipchat_api_key, 'username'=>TESTING_HIPCHAT_USERNAME}
  end

  describe "send_post" do
    before(:each) do
      puts testing_params
      @worker=SendHipChats.new(testing_params)
      @client = HipChat::Client.new(hipchat_api_key, api_version: 'v2')
      @room = @client[TESTING_HIPCHAT_ROOM]
    end
    
    it "should construct a client and a room and post the message" do
      expect(HipChat::Client).to receive(:new).with(test_post['api_token'], api_version: 'v2'){@client}
      expect(@client).to receive(:[]).with(TESTING_HIPCHAT_ROOM){@room}
      expect(@room).to receive(:send).with(TESTING_HIPCHAT_USERNAME, test_post['text'], notify: true)

      @worker.send_post(test_post)
    end
    
  end

  describe "execute" do
    before(:each) do
      @worker=SendHipChats.new(testing_params)
      @message = {post: "Some post"}.to_json
      @worker.queue.post(@message)
      @execute=lambda{
        @worker.execute
        @worker.queue.reload
      }
    end
    after(:each) do
      @worker.queue.clear if @worker.queue.size > 0
    end
    
    it "removes a message from the queue" do
      expect(@execute).to change(@worker.queue, :size)
    end

  end
end