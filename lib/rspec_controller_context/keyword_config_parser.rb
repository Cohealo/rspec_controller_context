module RspecControllerContext
  # Turns keyword args into a hash
  module KeywordConfigParser

    def self.keywords_to_hash(action: nil, method: nil, ajax: nil, **parameters)
      c = {}
      c[:action] = action         if action.present?
      c[:ajax] = ajax             if ajax.present?
      c[:method] = method         if method.present?
      c[:parameters] = parameters || {}

      # TODO: deal with parameters key of :parameters
      c
    end
  end
end
