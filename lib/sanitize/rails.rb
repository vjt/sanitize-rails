# Sanitize gem bridge and helpers
#
require 'sanitize'
require 'sanitize/railtie' if defined? Rails

module Sanitize::Rails
  Version = '0.6.0'

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
    # the Gem default configuration.
    #
    def cleaner
      @sanitizer ||= ::Sanitize.new(@@config || {})
    end

    # Returns a copy of the given `string` after sanitizing it
    #
    def clean(string)
      clean!(string.dup)
    end

    # Sanitizes the given `string` in place
    #
    def clean!(string)
      cleaner.clean!(string)
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
        def sanitize(string)
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
          unless field.blank?                      # def sanitize_fieldA_fieldB
            sanitized = Engine.clean(send(field))  #   self.fieldA = Engine.clean(self.fieldA) unless fieldA.blank?
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

  # Test instrumentation
  #
  module TestHelpers
    class << self
      # Instruments the given base class with the +assert_sanitizes+
      # helper, and memoizes the given options, accessible from the
      # helper itself via the +valid+ and +invalid+ methods.
      #
      # Those methods contains two HTML strings, one assumed to be
      # "invalid" and the other, well, "valid".
      #
      # In your ActiveSupport::Testcase:
      #
      #   Sanitize::Rails::TestHelpers.setup(self,
      #     :invalid => 'some <a>string',
      #     :valid   => 'some <a>string</a>'
      #   )
      #
      def setup(base, options = {})
        base.instance_eval { include TestHelpers }
        @@options = options
      end

      def valid;   @@options[:valid]   rescue nil end
      def invalid; @@options[:invalid] rescue nil end
    end

    # Verifies that the given `klass` sanitizes the given `fields`, by
    # checking both the presence of the sanitize callback and that it
    # works as expected, by setting the +invalid+ string first, invoking
    # the callback and then checking that the string has been changed
    # into the +valid+ one.
    #
    # If you pass an Hash as the last argument, it can contain `:valid`,
    # `:invalid` and `:object` keys. The first two ones override the
    # configured defaults, while the third executes assertions on the
    # specified object. If no :object is given, a new object is instantiated
    # by the given `klass` with no arguments.
    #
    # If neither `:valid`/`:invalid` strings are configured nor are passed
    # via the options, the two default strings in the method source are
    # used.
    #
    def assert_sanitizes(klass, *fields)
      options   = fields.extract_options!
      sanitizer = Engine.method_for(fields)

      # Verify the callback works
      invalid = options[:invalid] || TestHelpers.invalid || '<b>ntani<br>'
      valid   = options[:valid]   || TestHelpers.valid   || '<b>ntani<br /></b>'
      object  = options[:object]  || klass.new

      fields.each {|field| object.send("#{field}=", invalid)       }

      object.send sanitizer

      fields.each {|field| assert_equal(valid, object.send(field)) }
    end
  end
end
