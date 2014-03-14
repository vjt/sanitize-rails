require 'test_helper'

require 'action_view'
require 'sanitize'
require 'sanitize/rails'

# Test suite for Sanitize::Rails::Engine
class SanitizeRailsEngineTest < MiniTest::Unit::TestCase
  def setup
    @engine = Sanitize::Rails::Engine
  end

  def test_respond_to_configure
    assert_respond_to @engine, :configure
  end

  def test_respond_to_cleaner
    assert_respond_to @engine, :cleaner
  end

  def test_cleaner_returns_instance_of_sanitize
    assert_kind_of Sanitize, @engine.cleaner
  end

  def test_respond_to_clean_bang
    assert_respond_to @engine, :clean!
  end

  def test_clean_bang_modifies_string_in_place
    string = %Q|<script>alert("hello world")</script>|
    @engine.clean! string
    assert_equal string, %q|alert("hello world")|
  end

  def test_respond_to_clean
    assert_respond_to @engine, :clean
  end

  def test_clean_does_not_modify_string_in_place
    string = %Q|<script>alert("hello world")</script>|
    new_string = @engine.clean string
    assert_equal string, %Q|<script>alert("hello world")</script>|
    assert_equal new_string, 'alert("hello world")'
  end

  def test_clean_returns_safe_buffers
    string = %Q|<script>alert("hello world")</script>|
    assert_instance_of String, string

    new_string = @engine.clean string
    assert_instance_of ::ActiveSupport::SafeBuffer, new_string
  end
end
