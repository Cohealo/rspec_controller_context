     ____                         ____            _             _ _
    |  _ \ ___ _ __   ___  ___   / ___|___  _ __ | |_ _ __ ___ | | | ___ _ __
    | |_) / __| '_ \ / _ \/ __| | |   / _ \| '_ \| __| '__/ _ \| | |/ _ \ '__|
    |  _ <\__ \ |_) |  __/ (__  | |__| (_) | | | | |_| | | (_) | | |  __/ |
    |_| \_\___/ .__/ \___|\___|  \____\___/|_| |_|\__|_|  \___/|_|_|\___|_|
              |_|
                    ____            _            _
                   / ___|___  _ __ | |_ _____  _| |_
                  | |   / _ \| '_ \| __/ _ \ \/ / __|
                  | |__| (_) | | | | ||  __/>  <| |_
                   \____\___/|_| |_|\__\___/_/\_\\__|

# Rspec Controller Context

Helps manage request options in rails controller spec code. It provides
two methods,

* a class method on an example group called `request_config`,
* and an instance method on an example called `make_request`.

Its a better way to deal with request params then writting methods like
`def valid_options; ...; end` in every controller spec.

## Installation

Add a git submodule for this project to vendor:

    git submodule add https://github.com/ajh/rspec_controller_context.git vendor/rspec_controller_context

Then configure it in `spec/spec_helper.rb` like this:

    require Rails.root.join('vendor/rspec_controller_context/lib/rspec_controller_context')

    Rspec.configure do |config|
      ...
      config.include RspecControllerContext::ControllerDriver, :type => :controller
      ...
    end

## Example

This demonstrates a typical way to use the class method `request_config`
and the instance method `make_request`.

    describe UsersController do
      describe "POST create" do
        request_config method: :post, action: :create

        context "with title" do
          request_config title: 'Sgt'

          it 'should assign title' do
            make_request # runs `post :create, title: 'Sgt'
            expect(assigns[:user].title).to eq('Sgt')
          end
        end

        context "when invalid" do
          request_config destroyed_at: 1.week.ago

          it 'should fail' do
            make_request # runs `post :create, destroyed_at: 1.week.ago`
            expect(response.code).to eq(422)
          end
        end
      end
    end

## request_config

### configuring parameters

This class method takes keyword arguments. If the keyword name is one of
these reserved names: `action`, `method`, `ajax` it is treated specially. Otherwise the
keword is considered part of the parameters for the request. Here is an
example of setting parameters:

    describe "example" do
      request_config Iam: {a: 'parameter'}
      it "should blah" do
        make_request # the controller will see params = {Iam: {a:
'parameter'}}
      end
    end

If a parameter conflicts with one of the reserved names, it can nested
under a :parameter name like this:

    describe "example" do
      request_config parameter: {ajax: 'a param'}
      it "should blah" do
        make_request # the controller will see params = {ajax: 'a param'}
      end
    end

### configuring parameters with a proc

Parameters sometimes depend on factories or other things in the scope of
the rspec example. These are handled by passing a proc to `request_config` like this:

    describe "GET show" do
      let(:user) { FactoryGirl.create ... }
      request_config do
        {id: user.id}
      end
      it "should blah" do
        make_request # the controller will see params = {id: user.id}
      end
    end

### configuring action

An `action` keyword sets the request action:

    describe "example" do
      request_config action: 'index'
      it "should blah" do
        make_request # calls 'index' action
      end
    end

### configuring method

A `method` keyword sets the http method:

    describe "example" do
      request_config method: :put
      it "should blah" do
        make_request # uses the PUT http method
      end
    end

### configuring ajax

An `ajax` keyword, which takes a boolean, sets whether to use ajax. The
default is false.

    describe "example" do
      request_config ajax: true, method: :put
      it "should blah" do
        make_request # calls `xhr :put ...` instead of `:put ...`
      end
    end

### inheritance

`request_config` is inheritable. Nested `contexts` and `describes` will
inherit their parent's config. Changing a nested config will not effect
the parent's. For example:

    describe "parent" do
      request_config id: 123

      context "with id 4" do
        request_config id: 4

        it "should have correct id" do
          make_request # params = {id: 4}
        end
      end

      it "should have correct id" do
        make_request # params = {id: 123}
      end
    end

## make_request for controller specs

This instance method fires off a request based on the config. For
controller specs it'll call methods like:

    get :action, { ... parameters here ... }

It can also be passed any of the config (besides procs) as
`request_config`. For example:

    describe "example" do
      request_config id: 123
      it "should override id" do
        make_request id: 4 # the controller will see params = {id: 4}
'parameter'}}
      end
    end

## make_request for integration or request specs

TBD

## Planned features

Autodetecting method and action based on rspec example description using
the following convention: `describe "GET show" do`

Support for integration and request specs.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/rspec_controller_context/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
