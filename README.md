# Sanitize-Rails - sanitize .. on Rails. [![Build Status](https://travis-ci.org/vjt/sanitize-rails.png)](https://travis-ci.org/vjt/sanitize-rails)

## Installation

Gemfile:

    gem 'sanitize-rails', require: 'sanitize/rails'

## Configuration

config/initializers/sanitizer.rb:

    Sanitize::Rails.configure(
      elements:    [ ... ],
      attribiutes: { ... },
      ...
    )

There's an example in the `example/` directory.

## Usage

app/models/foo.rb:

    sanitizes :field
    sanitizes :some_other_field,  on: :create
    sanitizes :yet_another_field, on: :save

ActionView `sanitize` helper is overriden to use
the Sanitize gem - transparently.

## Testing

### Test::Unit

test/test\_helper:

    require 'sanitize/rails/test_helpers'

    Sanitize::Rails::TestHelpers.setup(self,
      invalid: 'some <a>string',
      valid:   'some <a>string</a>'
    )

your test:

    assert_sanitizes(Model, :field, :some_other_field)

### RSpec

spec/spec\_helper:

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

You should pass field names to matcher in the same way as you do with the `sanitize` call in the model, otherwise 
sanitize method won't be found in model

## Compatibility

Tested with Rails 3.0 and up under Ruby 1.9.3 and up.

## License

MIT

## :smiley: Have fun!
