module RspecControllerContext
  class InstanceNotBoundError < StandardError; end
  class InvalidBlockReturnValue < StandardError; end

  # Configuration object for request configs. This class has to have be
  # immutable to work with class_attribute correctly. That's why the #+ method
  # exists.
  class Configuration
    attr_accessor :config_list, :instance

    def initialize(list=[], instance=nil)
      @config_list = list
      @instance = instance
    end

    # Return new config object with given hash or block added
    # to us
    def add(config_or_block)
      self.class.new @config_list + Array.wrap(config_or_block)
    end

    # Return a new configuration object bound to the given instance. This
    # instance will be instance_eval'ed with any procs in the config.
    def bind(instance)
      self.class.new @config_list.dup, instance
    end

    # Return the compiled config. This will be a hash built by combining added
    # hashes and blocks.
    def config
      @config ||= compile
    end

    private

    def compile
      @config_list.inject({}) do |config, hash_or_proc|
        case hash_or_proc
        when Hash
          config.deep_merge hash_or_proc
        when Proc
          instance or raise InstanceNotBoundError
          c = instance.instance_eval(&hash_or_proc)
          c.is_a?(Hash) || c == nil or raise InvalidBlockReturnValue
          c ? config.deep_merge(c) : config
        end
      end
    end
  end
end
