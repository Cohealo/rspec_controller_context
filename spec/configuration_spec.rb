RSpec.describe RspecControllerContext::Configuration do
  subject(:config) { described_class.new }
  let(:instance) { double 'instance' }

  describe "add" do
    it "should return a new config" do
      c = config.add hi: 'there'
      expect(c).to_not eq config
    end
  end

  describe "bind" do
    it "should return a new config" do
      c = config.bind instance
      expect(c).to_not eq config
    end
  end

  describe "config" do
    context "with added hashes" do
      it "should return added hash" do
        c = config.add hi: 'there'
        expect(c.config).to eq hi: 'there'
      end
      it "should return merged hashes" do
        c = config.add(hi: 'there').add bye: 'now'
        expect(c.config).to eq hi: 'there', bye: 'now'
      end
    end

    context "with added blocks" do
      it "should raise when not bound" do
        c = config.add(-> { {hi: 'there'} })
        expect { c.config }.
          to raise_error(RspecControllerContext::InstanceNotBoundError)
      end
      it "should return hash returned from block" do
        c = config.add(proc { {hi: 'there'} })
        c = c.bind instance
        expect(c.config).to eq hi: 'there'
      end
      it "should raise if block doesn't return a hash or nil" do
        c = config.add proc { false }
        c = c.bind instance
        expect { c.config }.
          to raise_error(RspecControllerContext::InvalidBlockReturnValue)
      end
      it "should add nothing if proc returns nil" do
        c = config.add proc {}
        c = c.bind instance
        expect(c.config).to eq({})
      end
      it "should return merged hashes" do
        c = config.add(proc {{hi: 'there'}}).add proc {{bye: 'now'}}
        c = c.bind instance
        expect(c.config).to eq hi: 'there', bye: 'now'
      end
      it "should exec block in bound objects scope" do
        c = config.add proc {{hi: @hi}}
        instance.instance_variable_set "@hi", 'hi there'
        c = c.bind instance
        expect(c.config).to eq hi: 'hi there'
      end
    end

    it "should give precedence to last thing added" do
      c = config.add(hi: 'there', bye: 'now').
        add(proc { {hi: 'life', yo: 'yo!'} }).
        add bye: 'bye'
      c = c.bind instance
      expect(c.config).to eq hi: 'life', bye: 'bye', yo: 'yo!'
    end

    it "should deep merge" do
      c = config.add(user: {name: 'foo'}).
                 add(user: {posts: ['hi', 'bye']}).
                 add proc {{user: {name: 'bar'}}}
      c = c.bind instance

      expect(c.config).to eq user: {name: 'bar',
                                    posts: ['hi', 'bye']}
    end
  end
end
