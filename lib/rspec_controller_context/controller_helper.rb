module RspecControllerContext

  # Methods for configuring a request.
  module ControllerHelper
    def self.included(mod)
      mod.send :buildable_config, :request_config
    end

    def make_request(options={}, &block)
      config = request_config options, &block

      action = config.delete :action
      ajax = config.delete :ajax
      http_method = config.delete :method
      parameters = config

      args = [http_method, action, parameters]
      args.unshift :xhr if ajax

      send(*args)
    end
  end
end
