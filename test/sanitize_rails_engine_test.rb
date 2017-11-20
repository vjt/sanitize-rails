require 'test_helper'

# Test suite for Sanitize::Rails::Engine
class SanitizeRailsEngineTest < Minitest::Test
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
    assert_equal %q|alert("hello world")|, string
  end

  def test_respond_to_clean
    assert_respond_to @engine, :clean
  end

  def test_clean_does_not_modify_string_in_place
    string = %Q|<script>alert("hello world")</script>|
    new_string = @engine.clean string
    assert_equal %Q|<script>alert("hello world")</script>|, string
    assert_equal 'alert("hello world")', new_string
  end

  def test_clean_returns_safe_buffers
    string = %Q|<script>alert("hello world")</script>|
    assert_instance_of String, string

    new_string = @engine.clean string
    assert_instance_of ::ActiveSupport::SafeBuffer, new_string
  end

  def test_clean_not_producing_malicious_html_entities
    string = %Q|&lt;script&gt;hello & world&lt;/script&gt;|
    @engine.clean! string
    assert_equal "&lt;script&gt;hello &amp; world&lt;/script&gt;", string
  end

  def test_clean_not_making_explicit_html_entities
    string = %Q|<script>hello & world</script>|
    @engine.configure(entities_whitelist: { '&amp;': '&' })
    @engine.clean! string
    assert_equal "hello & world", string
  end

  def test_clean_making_html_entities
    string = %Q|<script>hello & world</script>|
    @engine.clean! string
    assert_equal "hello &amp; world", string
  end

  def test_clean_returns_blank_string_for_nil_input
    assert_equal @engine.clean(nil), ''
  end

  def test_clean_bang_returns_blank_string_for_nil_input
    assert_equal @engine.clean!(nil), ''
  end
end
