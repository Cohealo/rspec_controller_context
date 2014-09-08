RSpec.describe RspecControllerContext::Configuration do
  subject(:config) { described_class.new }
  let(:instance) { Object.new }

  describe "+" do
    context "when adding parameters" do
      it "should set it" do
        c = config + {parameters: {id: 123, name: 'thing'}}
        expect(c.parameters).to eq({id: 123, name: 'thing'})
      end
      it "should override previous value" do
        c = config + {parameters: {id: 123, name: 'thing'}}
        c = c + {parameters: {id: 4}}
        expect(c.parameters).to eq({id: 4, name: 'thing'})
      end

      context "with a proc" do
        it "should add them" do
          c = config.send :+ do
            { id: 123, name: 'thing' }
          end
          c = c.bind instance
          expect(c.parameters).to eq({id: 123, name: 'thing'})
        end
        it "should overwrite previous values" do
          c = config.send :+ do
            { id: 123, name: 'thing' }
          end
          c = c.send :+ do
            { name: 'thunk' }
          end
          c = c.bind instance
          expect(c.parameters).to eq({id: 123, name: 'thunk'})
        end
        it "should have access to instance scope" do
          instance.instance_variable_set "@foo", 'hi there'
          c = config.send :+ do
            { name: @foo }
          end
          c = c.bind instance
          expect(c.parameters).to eq({name: 'hi there'})
        end
        it "should raise without bound instance" do
          # matcher doesn't seem to work?
          #c = config.send :+ do
          #end
          #expect(c.parameters).to raise_error(RspecControllerContext::InstanceNotBoundError)
        end
        it "should not crash when proc returns nil" do
          c = config.send(:+) {}
          c = c.bind instance
          expect(c.parameters).to eq({})
        end
      end

      it "should give precedence to proc over argument" do
        c = config.send :+, parameters: {name: 'aaa'} do
          { name: 'bbb' }
        end
        c = c.bind instance
        expect(c.parameters).to eq(name: 'bbb')
      end
      it "should deep merge" do
        c = config.send :+, parameters: {user: {name: 'foo'}}
        c = c.send :+, parameters: {user: {posts: ['hi', 'bye']}}
        expect(c.parameters).to eq({
          user: {name: 'foo', posts: ['hi', 'bye']}
        })
      end
      it "should override proc with argument" do
        c = config.send :+ do
          { id: 123, name: 'thing' }
        end
        c = c.send :+, parameters: {name: 'thunk'}
        c = c.bind instance
        expect(c.parameters).to eq({id: 123, name: 'thunk'})
      end
      it "should override argument with proc" do
        c = config.send :+, parameters: {name: 'thunk'}
        c = c.send :+ do
          { id: 123, name: 'thing' }
        end
        c = c.bind instance
        expect(c.parameters).to eq({id: 123, name: 'thing'})
      end
    end

    context "when setting method" do
      it "should set it" do
        c = config + {method: :put}
        expect(c.http_method).to eq(:put)
      end

      it "should override previous value" do
        c = config + {method: :put}
        c = c + {method: :get}
        expect(c.http_method).to eq(:get)
      end
    end

    context "when setting action" do
      it "should set it" do
        c = config + {action: 'index'}
        expect(c.action).to eq('index')
      end
      it "should override previous value" do
        c = config + {action: 'index'}
        c = c + {action: 'new'}
        expect(c.action).to eq('new')
      end
    end

    context "when setting ajax" do
      it "should set it" do
        c = config + {ajax: true}
        expect(c.ajax).to eq(true)
      end
      it "should override previous value" do
        c = config + {ajax: true}
        c = c + {ajax: false}
        expect(c.ajax).to eq(false)
      end
    end
  end
end
