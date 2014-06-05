module Sanitize::Rails

  module Engine
    extend self

    def configure(config)
      @@config = config.freeze
    end

    # Returns a memoized instance of the Engine with the
    # configuration passed to the +configure+ method or with
    # the ActionView's default config
    #
    def cleaner
      @@config ||= begin
        {
          :elements   => ::ActionView::Base.sanitized_allowed_tags.to_a,
          :attributes => { :all => ::ActionView::Base.sanitized_allowed_attributes.to_a},
          :protocols  => { :all => ::ActionView::Base.sanitized_allowed_protocols.to_a }
        }
      rescue
        warn "ActionView not available, falling back to Sanitize's BASIC config"
        ::Sanitize::Config::BASIC
      end
      @sanitizer ||= ::Sanitize.new(@@config)
    end

    # Returns a copy of the given `string` after sanitizing it and marking it
    # as `html_safe`
    #
    # Ensuring this methods return instances of ActiveSupport::SafeBuffer
    # means that text passed through `Sanitize::Rails::Engine.clean`
    # will not be escaped by ActionView's XSS filtering utilities.
    def clean(string)
      ::ActiveSupport::SafeBuffer.new string.to_s.dup.tap { |s| clean!(s) }
    end

    # Sanitizes the given `string` in place and does NOT mark it as `html_safe`
    #
    def clean!(string)
      cleaner.clean!(string.to_s).to_s
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
  end
end
