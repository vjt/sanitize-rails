Sanitize-Rails - sanitize .. on Rails. [![Build Status](https://travis-ci.org/vjt/sanitize-rails.png)](https://travis-ci.org/vjt/sanitize-rails)
======================================

Installation
------------

Gemfile:

    gem 'sanitize-rails', :require => 'sanitize/rails'

Configuration
-------------

config/initializers/sanitizer.rb:

    Sanitize::Rails.configure(
      :elements    => [ ... ],
      :attribiutes => { ... },
      ...
    )

There's an example in the `example/` directory.

Usage
-----

app/models/foo.rb:

    sanitizes :field
    sanitizes :some_other_field,  :on => :create
    sanitizes :yet_another_field, :on => :save

ActionView `sanitize` helper is overriden to use
the Sanitize gem - transparently.

Testing
-------

Only Test::Unit for now - please write matchers
and send a pull request :-)

test/test\_helper:

    Sanitize::Rails::TestHelpers.setup(self,
      :invalid => 'some <a>string',
      :valid   => 'some <a>string</a>'
    )

your test:

    assert_sanitizes(Model, :field, :some_other_field)

Compatibility
-------------

Tested with Rails 3.0 ~ 4.0 under Ruby 1.9 and 2.0.

License
-------

MIT


Have fun!
