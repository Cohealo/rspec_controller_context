RSpec.describe RspecControllerContext::ControllerHelper do
  let(:example_group) do
    Class.new do
      extend RspecControllerContext
      include RspecControllerContext::ControllerHelper
    end
  end
  subject(:example) { example_group.new }

  describe "included hook" do
    it "should setup buildable option" do
      expect(example_group).to respond_to :request_config
      expect(example).to respond_to :request_config
    end
  end

  describe "#make_request" do
    it "should make request" do
      example_group.request_config action: 'show', method: :get, id: 101
      expect(example).to receive(:get).with('show', id: 101)
      example.make_request
    end

    context 'when ajax is true' do
      it "should call xhr method" do
        example_group.request_config ajax: true, action: 'show', method: :get, id: 101
        expect(example).to receive(:xhr).with(:get, 'show', id: 101)
        example.make_request
      end
    end

    context 'when passed config' do
      it "should be used" do
        example_group.request_config action: 'show', method: :get, id: 101, form: 'login'
        expect(example).to receive(:head).with('show', id: 101, form: 'foo', hi: 'there')
        example.make_request method: :head, form: 'foo', hi: 'there'
      end
      it "should not effect classes config" do
        example_group.request_config action: 'show', method: :get
        allow(example).to receive(:head)
        example.make_request method: :head

        expect(example).to receive(:get).with 'show', anything
        example.make_request
      end
    end

    context "when procs are used" do
      it "should work" do
        example_group.request_config action: 'show', method: :get do
          {id: 101}
        end
        expect(example).to receive(:get).with('show', id: 101)
        example.make_request
      end
    end

    context 'when http_method not defined' do
      # using a convention like:
      #
      #   describe "GET show" do
      #     ...
      it "should try to guess from the example's description"

      context "when action is a standard REST action" do
        {
          index: :get,
          new: :get,
          create: :post,
          edit: :get,
          update: :put, # or is it PATCH these days?
          destroy: :delete,
        }.each do |action, method|
          it "should guess the method when action is #{action}" do
            expect(example).to receive(method)
            example.make_request action: action
          end
        end
      end

      it "should raise without being able to guess" do
        expect {example.make_request}.
          to raise_error RspecControllerContext::IncompleteRequestError
      end
    end

    context 'when action not defined' do
      it "should try to guess form the example's description"
    end
  end
end
