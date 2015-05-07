# Sanitize-Rails - sanitize .. on Rails. [![Build Status](https://travis-ci.org/vjt/sanitize-rails.png)](https://travis-ci.org/vjt/sanitize-rails)

An easy bridge to integrate Ryan Grove's [HTML Whitelist Sanitizer][sanitize]
in your Rails application.

## Installation

`Gemfile`:

    gem 'sanitize-rails', require: 'sanitize/rails'

## Configuration

Pass the configuration to `Sanitize` calling `Sanitize::Rails.configure` in
an initializer, say `config/initializers/sanitizer.rb`:

    Sanitize::Rails.configure(
      elements:   [ ... ],
      attributes: { ... },
      ...
    )

You may pass `skip_escaping_entities: true` if you don't want to escape
html entities. Example: `Hello & World` will not be changed to
`Hello &amp; World`

Check out the [example][] in the `example/` directory.

## Usage

ActionView `sanitize` helper is transparently overriden to use the `Sanitize`
gem.

A `sanitize` helper is added to `ActiveRecord`, that installs on create/save
callbacks that sanitize the given attributes before persisting them to the
database. Example:

`app/models/foo.rb`:

    class Foo < ActiveRecord::Base
      sanitizes :description # on save by default

      sanitizes :body,    on: :create
      sanitizes :remarks, on: :save
    end

## Testing

### RSpec

`spec/spec_helper.rb`:

    require 'sanitize/rails/matchers'

in spec code:

    describe Post do
      # Simplest variant, single field and default values
      it { should sanitize_field :title }

      # Multiple fields
      it { should sanitize_fields :title, :body }

      # Specifing both text to sanitize and expected result
      it { should sanitize_field(:title).replacing('&copy;').with('©') }
    end

You should pass field names to matcher in the same way as you do with the
`sanitize` call in the model, otherwise sanitize method won't be found in
model.

### Test::Unit

`test/test_helper.rb:`

    require 'sanitize/rails/test_helpers'

    Sanitize::Rails::TestHelpers.setup(self,
      invalid: 'some <a>string',
      valid:   'some <a>string</a>'
    )

your test:

    assert_sanitizes Model, :field, :some_other_field

## Compatibility

Tested with Rails 3.0 and :up: under Ruby 1.9.3 and :up:.

## License

MIT

## :smiley: Have fun!

[sanitize]: https://github.com/rgrove/sanitize
[example]: https://github.com/vjt/sanitize-rails/blob/master/example/sanitizer.rb
