module RspecControllerContext
  # A mixin for controller specs
  module ControllerDriver
    def self.included(klass)
      klass.send :extend, ClassMethods
    end

    def make_request(action: nil, method: nil, ajax: nil, **parameters)
      local_config = KeywordConfigParser.keywords_to_hash \
        action: action,
        method: method,
        ajax: ajax,
        **parameters

      bound_config = self.class.rspec_controller_context_config.bind self

      action = local_config[:action]      || bound_config.action
      ajax = local_config[:ajax]          || bound_config.ajax
      http_method = local_config[:method] || bound_config.http_method
      parameters = bound_config.parameters.merge(local_config[:parameters])

      args = [http_method, action, parameters]
      args.unshift :xhr if ajax

      send(*args)
    end
  end
end
