# This is similar to the other test but tries to flush out rspec version errors
# by actually including into rspec
RSpec.describe RspecControllerContext do
  extend RspecControllerContext

  buildable_config :test_config

  it "responds to test_config class method" do
    expect(self.class).to respond_to :test_config
  end

  it "responds to test_config instance method" do
    expect(self).to respond_to :test_config
  end

  describe "instance method" do
    context "with nothing added" do
      it "should return an empty hash" do
        expect(self.test_config).to eq({})
      end
    end

    context "with added hashes" do
      test_config hi: 'there'
      test_config bye: 'now'

      it "should return merged hashes" do
        expect(self.test_config).to eq hi: 'there', bye: 'now'
      end
    end

    context "with added blocks" do
      test_config { {hi: @hi} }
      test_config { {bye: 'now'} }

      it "should return merged hashes" do
        @hi = 'there'
        expect(self.test_config).to eq hi: 'there', bye: 'now'
      end
    end

    context "with a mix of hashes and blocks" do
      test_config user: {name: 'foo'}
      test_config {{user: {name: 'bar'}}}
      test_config user: {posts: ['hi', 'bye']}

      it "should deep merge" do
        expect(self.test_config).
          to eq user: {name: 'bar', posts: ['hi', 'bye']}
      end
    end
  end
end
