module RspecControllerContext
  class IncompleteRequestError < StandardError; end

  # Mixin for rails controller specs. Sets up a buildable config called
  # request_config and provides a method to fire off requests called
  # make_request.
  module ControllerHelper
    def self.included(mod)
      mod.extend RspecControllerContext
      mod.send :buildable_config, :request_config
    end

    # Make a call to the ActionController::TestCase stuff based on the request
    # config. Expects :action and :method to be set at least, although in some
    # cases we can guess these values.
    #
    # If an :ajax option has a true value, it'll make a xml_http_request.
    #
    # All other options are considered parameters.
    #
    def make_request(options={}, &block)
      config = request_config options, &block

      action = config.delete :action
      ajax = config.delete :ajax
      http_method = config.delete :method
      http_method ||= guess_method_from_action action
      parameters = config

      if http_method.blank? || action.blank?
        msg = if http_method.blank? && action.blank?
                ":method and :action are unconfigured"
              elsif http_method.blank?
                ":method unconfigured"
              elsif action.blank?
                ":action unconfigured"
              end
        raise IncompleteRequestError, msg
      end
      args = [http_method, action, parameters]
      args.unshift :xhr if ajax

      send(*args)
    end

    private

    def guess_method_from_action(action)
      case action.to_s
      when "index"; :get
      when "new"; :get
      when "create"; :post
      when "edit"; :get
      when "update"; :put
      when "destroy"; :delete
      end
    end
  end
end
