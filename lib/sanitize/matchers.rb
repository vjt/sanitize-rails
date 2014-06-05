module Sanitize::Matchers

  # RSpec custom matcher to check for field sanitization
  #
  # Verifies that the matcher subject sanitizes the given `fields`, by
  # checking that the sanitize callback works as expected.
  #
  # Matcher can be used in the following variants:
  #
  #   describe Post do
  #     # Simplest variant, single field and default values
  #     it { should sanitize_field :title }
  #     # Multiple fields
  #     it { should sanitize_fields :title, :body }
  #     # Specifing both text to sanitize and expected result
  #     it { should sanitize_field(:title).replacing('&copy;').with('©') }
  #   end
  #
  def sanitize_field(*fields)
    if fields.empty?
      raise ArgumentError, 'need at least one argument'
    else
      SanitizeFieldsMatcher.new(*fields)
    end
  end

  # Sintactic sugar
  alias_method :sanitize_fields, :sanitize_field

  # Add matchers module to rspec configuration
  RSpec.configure { |c| c.include(self) } if defined? RSpec and RSpec.respond_to?(:configure)

  # Actual matcher class
  class SanitizeFieldsMatcher

    # Take an array of fields to check, they must respect the same order given in model `sanitize` call
    def initialize(*fields)
      self.options = fields.extract_options!
      self.sanitizer = ::Sanitize::Rails::Engine.method_for(fields)
      self.fields = fields
    end

    # Used to specify invalid text assigned to fields
    def replacing(invalid)
      @invalid_changed = true
      @invalid = invalid
      self
    end

    # Used to specify expected output for the invalid text
    def with(valid)
      @valid_changed = true
      @valid = valid
      self
    end

    # Actual match code
    def matches?(instance)
      self.instance = instance
      # assign invalid value to each field
      fields.each { |field| instance.send("#{field}=", invalid_value) }
      # sanitize the object calling the method
      instance.send(sanitizer) rescue nil
      # check expectation on results
      fields.all? { |field| valid_value == instance.send(field) }
    end

    def failure_message_for_should
      "Expected #{should_helper} to return sanitized value '#{valid_value}', got '#{attribute_values}'"
    end

    def failure_message_for_should_not
      "Expected #{field_helper} not to be sanitized"
    end

    def description
      "sanitize #{should_helper}"
    end

    private

    attr_accessor :options, :sanitizer, :instance, :fields

    def invalid_value
      @invalid ||= '<b>valid<br>'
    end

    def valid_value
      @valid ||= '<b>valid<br></b>'
    end

    def custom_values?
      @invalid_changed && @invalid_changed
    end

    def field_helper
      "#{'field'.pluralize(fields.count)} #{fields.to_sentence}"
    end

    def should_helper
      field_helper.tap do |desc|
        desc << " by replacing '#{invalid_value}' with '#{valid_value}'" if custom_values?
      end
    end

    def attribute_values
      instance.attributes.slice(*fields.map(&:to_s))
    end

  end

end


