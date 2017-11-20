module Sanitize::Rails

  module Engine
    extend self

    # Changes the Sanitizer configuration.
    #
    def configure(config)
      @_config = config.freeze
      @_cleaner = nil
    end

    # Returns the current Sanitizer configuration. The configuration is built
    # from Rails configuration, if defined, else Sanitize::Config::BASIC is
    # used.
    #
    # FIXME: Remove this, as it is meant only not to break assumptions on old
    # applications.
    #
    if defined?(::ActionView::Base) &&
      ::ActionView::Base.respond_to?(:sanitized_allowed_tags) &&
      ::ActionView::Base.sanitized_allowed_tags.respond_to?(:size) &&
      ::ActionView::Base.sanitized_allowed_tags.size > 0

      def config
	@_config ||= {
	  :elements => ::ActionView::Base.sanitized_allowed_tags.to_a,
	  :attributes => { :all => ::ActionView::Base.sanitized_allowed_attributes.to_a },
	  :protocols  => { :all => ::ActionView::Base.sanitized_allowed_protocols.to_a },
	  :entities_whitelist => {}
	}
      end
    else
      def config
	@_config ||= ::Sanitize::Config::BASIC
      end
    end

    # Returns a memoized instance of the Engine with the
    # configuration passed to the +configure+ method or with
    # the ActionView's default config
    #
    def cleaner
      @_cleaner ||= ::Sanitize.new(config)
    end

    # Returns a copy of the given `string` after sanitizing it and marking it
    # as `html_safe`
    #
    # Ensuring this methods return instances of ActiveSupport::SafeBuffer
    # means that text passed through `Sanitize::Rails::Engine.clean`
    # will not be escaped by ActionView's XSS filtering utilities.
    def clean(string)
      ::ActiveSupport::SafeBuffer.new cleaned_fragment(string)
    end

    # Sanitizes the given `string` in place and does NOT mark it as `html_safe`
    #
    def clean!(string)
      return '' if string.nil?
      string.replace cleaned_fragment(string)
    end

    def callback_for(options) #:nodoc:
      point = (options[:on] || 'save').to_s

      unless %w( save create ).include?(point)
	raise ArgumentError, "Invalid callback point #{point}, valid ones are :save and :create"
      end

      "before_#{point}".intern
    end

    def method_for(fields) #:nodoc:
      "sanitize_#{fields.join('_')}".intern
    end

    private

    def decode_whitelisted_entities(string)
      @_config[:entities_whitelist].each do |entity, decoded_value|
        string.gsub!(entity.to_s, decoded_value.to_s)
      end

      string
    end

    def cleaned_fragment(string)
      sanitized_string = cleaner.fragment(string)

      if @_config[:entities_whitelist].present?
        sanitized_string = decode_whitelisted_entities(sanitized_string)
      end

      return sanitized_string
    end
  end
end
