require 'minitest/unit'
require 'minitest/autorun'

require 'minitest/reporters'

# Avoid using terminal escape codes for color if
# the current terminal does not support it
if ENV['term'] || ENV['color']
  Minitest::Reporters.use!
else
  Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new
end
