module Sanitize::Rails

  # Adds two `sanitize_as_html{,!}` helpers to String itself,
  # that call +Engine#clean+ or +Engine#clean!+ in turn
  #
  module String
    # Calls +Engine#clean+ on this String instance
    #
    def sanitize_as_html
      Engine.clean(self)
    end

    # Calls +Engine#clean!+ on this String instance
    #
    def sanitize_as_html!
      Engine.clean!(self)
    end
  end

end
