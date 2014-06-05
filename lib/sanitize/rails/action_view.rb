module Sanitize::Rails

  module ActionView # :nodoc:
    def self.included(base)
      base.class_eval do
        # To make sure we're called *after* the method is defined
        undef_method :sanitize

        # Overrides ActionView's sanitize() helper to use +Engine#clean+
        #
        # FIXME: Options are currently ignored.
        #
        def sanitize(string, options = {})
          Engine.clean(string)
        end
      end
    end
  end

end
