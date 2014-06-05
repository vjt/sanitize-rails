# Sanitize gem bridge and helpers
#
require 'sanitize'
require 'sanitize/railtie' if defined? Rails

module Sanitize::Rails

  # Configures the sanitizer with the given `config` hash.
  #
  # In your environment.rb, in the after_initialize block:
  #
  #   Sanitize::Rails.configure(
  #     :elements => [ ... ],
  #     :attributes => [ ... ],
  #     ...
  #   )
  #
  def self.configure(config)
    Engine.configure(config)
  end

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

  module ActionView
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

  # Adds the +sanitizes+ method to ActiveRecord children classes
  #
  module ActiveRecord
    # Generates before_save/before_create filters that implement
    # sanitization on the given fields, in the given callback
    # point.
    #
    # Usage:
    #
    #   sanitizes :some_field, :some_other_field #, :on => :save
    #
    # Valid callback points are :save and :create, callbacks are installed "before_"
    # by default. Generated callbacks are named with the "sanitize_" prefix follwed
    # by the field names separated by an underscore.
    #
    def sanitizes(*fields)
      options   = fields.extract_options!
      callback  = Engine.callback_for(options)
      sanitizer = Engine.method_for(fields)

      define_method(sanitizer) do                  # # Unrolled version
        fields.each do |field|                     #
          value = send(field)
          unless value.blank?                      # def sanitize_fieldA_fieldB
            sanitized = Engine.clean(value)        #   self.fieldA = Engine.clean(self.fieldA) unless fieldA.blank?
            send("#{field}=", sanitized)           #   self.fieldB = Engine.clean(self.fieldB) unless fieldB.blank?
          end                                      # end
        end                                        #
      end                                          # end

      protected sanitizer                          # protected :sanitize_fieldA_fieldB
      send callback, sanitizer                     # before_save :sanitize_fieldA_fieldB
    end
  end

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
