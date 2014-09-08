module RspecControllerContext
  # class methods for configuring a request.
  module ClassMethods
    def self.extended(klass)
      klass.send :class_attribute, :rspec_controller_context_config
      klass.rspec_controller_context_config = Configuration.new
    end

    def request_config(action: nil, method: nil, ajax: nil, **parameters, &block)
      c = KeywordConfigParser.keywords_to_hash \
        action: action,
        method: method,
        ajax: ajax,
        **parameters

      self.rspec_controller_context_config = \
        rspec_controller_context_config.send :+, c, &block

      true
    end
  end
end
