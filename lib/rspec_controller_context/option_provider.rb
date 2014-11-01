module RspecControllerContext
  class AlreadyDefinedError < StandardError; end
  class MethodNameConflictError < StandardError; end
  class InvalidOptionNameError < StandardError; end

  # A module that contains the implementations for a buildable_config so just a
  # little code is added to the caller.
  module OptionProvider
    def self.define_option(name, mod)
      valid_method_name? name or raise InvalidOptionNameError
      name = name.to_sym

      !mod.respond_to? option_reader(name) or raise AlreadyDefinedError
      mod.send :class_attribute, option_reader(name)
      mod.send option_writer(name), Configuration.new

      !mod.methods.include? name or raise MethodNameConflictError
      !mod.instance_methods.include? name or raise MethodNameConflictError
      mod.class_eval <<-END
        def self.#{name}(options={}, &block)
          OptionProvider.add_to_option #{name.inspect}, self, options, &block
        end

        def #{name}(options={}, &block)
          OptionProvider.compile_option #{name.inspect}, self, options, &block
        end
      END
    end

    # The class method is used to build up the config. It can take a hash
    # argument and a block. A block will be eval'ed in the scope of the rspec
    # example (the "it" block). The class method can be called multiple times
    # to continue building the config. Later calls will overwrite values from
    # earlier calls if there are conflicts.
    #
    def self.add_to_option(name, mod, options={}, &block)
      if options.present?
        mod.send option_writer(name), mod.send(option_reader(name)).add(options)
      end
      if block.present?
        mod.send option_writer(name), mod.send(option_reader(name)).add(block)
      end

      true
    end

    # The instance method
    def self.compile_option(name, instance, options={}, &block)
      c = instance.class.send option_reader(name)
      if options.present?
        c = c.add options
      end
      if block.present?
        c = c.add block
      end

      c.bind(instance).config
    end

    private

    def self.valid_method_name?(name)
      m = name.to_s.match %r/^[a-zA-Z_][a-zA-Z_0-9]*[!?=]?$/
      m.present?
    end

    def self.option_reader(name)
      "buildable_test_options_#{name}"
    end

    def self.option_writer(name)
      "#{option_reader(name)}="
    end
  end
end
