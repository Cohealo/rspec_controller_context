module RspecControllerContext
  class InstanceNotBoundError < StandardError
  end

  # Configuration object for request configs. This class has to have be
  # immutable to work with class_attribute correctly. That's why the #+ method
  # exists.
  class Configuration
    attr_accessor :config_list, :instance

    def initialize(list=[], instance=nil)
      @config_list = list
      @instance = instance
    end

    # Combine this config with passed hash and block. Return new config object.
    def +(config={}, &block)
      list = []
      list << config if config.present?
      list << block if block.present?

      self.class.new @config_list + list
    end

    # Return a new configuration object bound to the given instance. This
    # instance will be instance_eval'ed with any procs in the config.
    def bind(instance)
      self.class.new @config_list.dup, instance
    end

    def parameters
      compile!
      @compiled_config[:parameters] || {}
    end

    def http_method
      compile!
      @compiled_config[:method]
    end

    def action
      compile!
      @compiled_config[:action]
    end

    def ajax
      compile!
      @compiled_config[:ajax]
    end

    private

    def compile!
      unless @compiled_config
        @compiled_config = @config_list.inject({}) do |config, hash_or_proc|
          case hash_or_proc
          when Proc
            instance or raise InstanceNotBoundError
            c = instance.instance_eval(&hash_or_proc)
            if c.present? && c.is_a?(Hash)
              config.deep_merge parameters: c
            else
              config
            end
          when Hash
            config.deep_merge hash_or_proc
          end
        end
      end

      @compiled_config
    end
  end
end
