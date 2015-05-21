#
# Sanitize Gem Bridge and Helpers for Rails
#
# https://github.com/vjt/sanitize-rails
#
# (C) 2011-2014 vjt@openssl.it
#
# MIT License
#
require 'sanitize'
require 'htmlentities'
require 'sanitize/rails/railtie' if defined? Rails

module Sanitize::Rails
  autoload :Engine,       'sanitize/rails/engine'
  autoload :ActionView,   'sanitize/rails/action_view'
  autoload :ActiveRecord, 'sanitize/rails/active_record'
  autoload :String,       'sanitize/rails/string'
  autoload :VERSION,      'sanitize/rails/version'

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
end
