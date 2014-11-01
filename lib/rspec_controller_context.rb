require "active_support/concern"
require "active_support/core_ext/class"
require "active_support/core_ext/hash"

require File.expand_path("../rspec_controller_context/configuration", __FILE__)
require File.expand_path("../rspec_controller_context/controller_helper", __FILE__)
require File.expand_path("../rspec_controller_context/option_provider", __FILE__)
require File.expand_path("../rspec_controller_context/version", __FILE__)

module RspecControllerContext
  # Create a new buildable config called "name". For example:
  #
  #     RSpec.describe ShoesController do
  #       # This will add a class and instance method called shoe_config
  #       buildable_config :shoe_config
  #
  #       shoe_config type: 'sneaker'
  #
  #       context "when laces are tied" do
  #         shoe_config tied: true
  #
  #         it "should not fall off" do
  #           attrs = shoes_config # => {type: 'sneaker', tied: true}
  #           expect(Shoe.new(attrs)).to be_secure
  #         end
  #       end
  #     end
  #
  # Defining a buildable config creates a class method and instance method
  # with the given name.
  #
  # The class method is used to build up the config. It can take a hash
  # argument and a block. A block will be eval'ed in the scope of the rspec
  # example (the "it" block). The class method can be called multiple times
  # to continue building the config. Later calls will overwrite values from
  # earlier calls if there are conflicts.
  #
  # The instance method will return a config hash as defined for that
  # example.
  def buildable_config(name)
    OptionProvider.define_option name, self
  end
end
