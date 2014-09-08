RSpec.describe RspecControllerContext::ControllerDriver do
  let(:example_group) do
    Class.new { include RspecControllerContext::ControllerDriver }
  end
  subject(:example) { example_group.new }

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
    end

    context 'when action not defined' do
      it "should try to guess form the example's description"
    end
  end
end
