RSpec.describe RspecControllerContext do
  subject(:klass) do
    Class.new { extend RspecControllerContext }
  end

  describe "buildable_config" do
    it "should add class method to class" do
      klass.buildable_config :test_config
      expect(klass).to respond_to(:test_config)
    end

    it "should add instance method to class" do
      klass.buildable_config :test_config
      expect(klass.new).to respond_to(:test_config)
    end

    it "should add class_attribute to class" do
      klass.buildable_config :test_config
      expect(klass).to respond_to(:buildable_test_options_test_config)
    end

    it "should raise if already defined" do
      klass.buildable_config :test_config
      expect {
        klass.buildable_config :test_config
      }.to raise_error(RspecControllerContext::AlreadyDefinedError)
    end
    it "should raise if class method already defined" do
      klass.class_eval "def self.test_config; true; end"
      expect {
        klass.buildable_config :test_config
      }.to raise_error(RspecControllerContext::MethodNameConflictError)
    end
    it "should raise if instance method already defined" do
      klass.class_eval "def test_config; true; end"
      expect {
        klass.buildable_config :test_config
      }.to raise_error(RspecControllerContext::MethodNameConflictError)
    end
    it "should raise is name is bad" do
      expect {
        klass.buildable_config 1234
      }.to raise_error(RspecControllerContext::InvalidOptionNameError)
    end
  end

  describe "class method" do
    before { klass.buildable_config :test_config }

    it "should return true" do
      expect(klass.test_config).to eq true
    end
  end

  describe "instance method" do
    before { klass.buildable_config :test_config }
    subject(:instance) { klass.new }

    context "with nothing added" do
      it "should return an empty hash" do
        expect(instance.test_config).to eq({})
      end
    end

    context "with added hashes" do
      it "should return added hash" do
        klass.test_config hi: 'there'
        expect(instance.test_config).to eq hi: 'there'
      end
      it "should return merged hashes" do
        klass.test_config hi: 'there'
        klass.test_config bye: 'now'
        expect(instance.test_config).to eq hi: 'there', bye: 'now'
      end
    end

    context "with added blocks" do
      it "should return hash returned from block" do
        klass.test_config { {hi: 'there'} }
        expect(instance.test_config).to eq hi: 'there'
      end
      it "should raise if block doesn't return a hash or nil" do
        klass.test_config { false }
        expect { instance.test_config }.
          to raise_error(RspecControllerContext::InvalidBlockReturnValue)
      end
      it "should add nothing if proc returns nil" do
        klass.test_config {}
        expect(instance.test_config).to eq({})
      end
      it "should return merged hashes" do
        klass.test_config { {hi: 'there'} }
        klass.test_config { {bye: 'now'} }
        expect(instance.test_config).to eq hi: 'there', bye: 'now'
      end
      it "should exec block in bound objects scope" do
        klass.test_config { {hi: @hi} }
        instance.instance_variable_set "@hi", 'hi there'
        expect(instance.test_config).to eq hi: 'hi there'
      end
    end

    context "with a mix of hashes and blocks" do
      it "should give precedence to last thing added" do
        klass.test_config hi: 'there', bye: 'now'
        klass.test_config { {hi: 'life', yo: 'yo!'} }
        klass.test_config bye: 'bye'
        expect(instance.test_config).
          to eq hi: 'life', bye: 'bye', yo: 'yo!'
      end

      it "should deep merge" do
        klass.test_config user: {name: 'foo'}
        klass.test_config {{user: {name: 'bar'}}}
        klass.test_config user: {posts: ['hi', 'bye']}
        expect(instance.test_config).
          to eq user: {name: 'bar', posts: ['hi', 'bye']}
      end
    end

    context "with arguments" do
      it "should return passed hash" do
        expect(instance.test_config(hi: 'there')).to eq hi: 'there'
      end
      it "should return value from passed block" do
        expect(instance.test_config {{hi: 'there'}}).to eq hi: 'there'
      end
      it "should merge arguments with existing values" do
        klass.test_config hi: 'there'
        expect(instance.test_config {{bye: 'now'}}).
          to eq hi: 'there', bye: 'now'
      end
      it "should have precedence over existing values" do
        klass.test_config hi: 'there'
        expect(instance.test_config(hi: 'bye')).
          to eq hi: 'bye'
      end
      it "should not update classes options" do
        klass.test_config hi: 'there'
        instance.test_config bye: 'now'
        expect(klass.new.test_config).to eq hi: 'there'
      end
      it "should not update instances options" do
        klass.test_config hi: 'there'
        instance.test_config bye: 'now'
        expect(instance.test_config).to eq hi: 'there'
      end
    end
  end

  context "when inherited" do
    before do
      klass.buildable_config :test_config
      klass.test_config hi: 'there'
    end
    let!(:subclass) do
      Class.new klass do
        test_config bye: 'now'
      end
    end

    it "should allow subclass to change config" do
      expect(subclass.new.test_config).to eq hi: 'there', bye: 'now'
    end

    it "should not change superclass when subclass changes" do
      expect(klass.new.test_config).to eq hi: 'there'
    end
  end

  context "when multiple build_options defined" do
    before do
      klass.buildable_config :foo_config
      klass.buildable_config :bar_config
    end
    let(:instance) { klass.new }

    it "they should both work independently" do
      klass.foo_config foo: true
      klass.bar_config bar: 'okay'

      expect(instance.foo_config).to eq foo: true
      expect(instance.bar_config).to eq bar: 'okay'
    end
  end

  # TODO: move this spec
  describe "valid_method_name?" do
    {
      "a_good_name" => true,
      "Okay" => true,
      "fine?" => true,
      "fine=" => true,
      "find!" => true,
      "ab?cd" => false,
      "okay123" => true,
      "123okay" => false,
      "_fine" => true,
      "$" => false,
    }.each do |name, is_valid|
      it "should return #{is_valid} for #{name.inspect}" do
        expect(RspecControllerContext::OptionProvider.send(:valid_method_name?, name)).
          to eq is_valid
      end
    end
  end
end
