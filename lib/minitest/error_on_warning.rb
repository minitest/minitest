module Minitest

  module ErrorOnWarning
    def warn(message, category: nil)
      message = "[#{category}] #{message}" if category
      raise UnexpectedWarning, message
    end
  end

  ::Warning.singleton_class.prepend(ErrorOnWarning)
end
