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

This gem helps manage request options in rails controller spec code. Its
a better way then writting methods like `def valid_options; ...; end` in
every controller spec.

## Installation

Add this line to your application's Gemfile:

    gem 'rspec_controller_context'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec_controller_context

Then configure it in `spec/spec_helper.rb` like this:

    Rspec.configure do |config|
      ...
      config.include RspecControllerContext::ControllerDriver :type => :controller
      ...
    end

## Example

    describe UsersController do
      describe "POST create" do
        request_config method: :post, action: :create

        context "with title" do
          request_config title: 'Sgt'

          it 'should assign title' do
            make_request
            expect(assigns[:user].title).to eq('Sgt')
          end
        end

        context "when invalid" do
          request_config destroyed_at: 1.week.ago

          it 'should fail' do
            make_request
            expect(response.code).to eq(422)
          end
        end
      end
    end

## Contributing

1. Fork it ( https://github.com/[my-github-username]/rspec_controller_context/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
