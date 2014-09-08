RSpec.describe RspecControllerContext::ClassMethods do
  subject(:example_group) do
    Class.new { extend RspecControllerContext::ClassMethods }
  end
  let(:configuration) { example_group.rspec_controller_context_config }

  describe "extended hook" do
    it "should setup a class_attribute" do
      expect(example_group).to respond_to(:rspec_controller_context_config)
      expect(example_group.rspec_controller_context_config).to be_a(RspecControllerContext::Configuration)
    end
  end

  describe "configuration inheritance" do
    let(:subclass) { Class.new example_group }

    context "when subclass changes its config" do
      it "should not change parents config" do
        example_group.request_config method: :put, action: 'index'
        subclass.request_config method: :get

        expect(subclass.rspec_controller_context_config.http_method).to eq(:get)
        expect(example_group.rspec_controller_context_config.http_method).to eq(:put)
      end
    end
  end

  describe ".request_config" do
    it "should return true" do
      # so we don't leak private instance variables
      expect(example_group.request_config).to eq(true)
    end

    context "with action keyword" do
      it "sets action" do
        expect(configuration).to receive(:+).with(hash_including(action: 'index'))
        example_group.request_config action: 'index'
      end
    end

    context "with method keyword" do
      it "sets method" do
        expect(configuration).to receive(:+).with(hash_including(method: :put))
        example_group.request_config method: :put
      end
    end

    context "with ajax keyword" do
      it "sets ajax" do
        expect(configuration).to receive(:+).with(hash_including(ajax: true))
        example_group.request_config ajax: true
      end
    end

    context "with parameters" do
      it "sets parameters" do
        expect(configuration).to receive(:+).with(hash_including(parameters: {id: 123, name: 'thing'}))
        example_group.request_config id: 123, name: 'thing'
      end
    end

    context "with a block" do
      # not sure how to test this...
    end
  end
end
