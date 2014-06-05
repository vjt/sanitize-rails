module Sanitize::Rails

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
