require 'test_helper'

# Test suite for Sanitize::Rails::Engine
class SanitizeRailsStringExtensionTest < Minitest::Test
  SanitizableString = Class.new(String) { include Sanitize::Rails::String }

  def setup
    @string = SanitizableString.new %Q|<script>alert("hello world")</script>|
  end

  def test_respond_to_sanitize_as_html_bang
    assert_respond_to @string, :sanitize_as_html!
  end

  def test_sanitize_as_html_bang_does_not_return_safe_buffers
    sanitizable_string = @string.dup
    assert_instance_of SanitizableString, sanitizable_string

    new_string = sanitizable_string.sanitize_as_html!
    assert_instance_of SanitizableString, new_string
  end

  def test_respond_to_sanitize_as_html
    assert_respond_to @string, :sanitize_as_html
  end

  def test_sanitize_as_html_returns_safe_buffers
    sanitizable_string = @string.dup
    assert_instance_of SanitizableString, sanitizable_string

    new_string = sanitizable_string.sanitize_as_html
    assert_instance_of ::ActiveSupport::SafeBuffer, new_string
  end
end
