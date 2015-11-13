# -*- encoding: utf-8 -*-
#
$:.push File.expand_path("../lib", __FILE__)

require 'sanitize/rails/version'

Gem::Specification.new do |s|
  s.name          = "sanitize-rails"
  s.version       = Sanitize::Rails::VERSION
  s.date          = "2014-06-05"
  s.authors       = ["Marcello Barnaba", "Damien Wilson", "Fabio Napoleoni"]
  s.email         = ["vjt@openssl.it", "damien@mindglob.com", "f.napoleoni@gmail.com"]
  s.homepage      = "http://github.com/vjt/sanitize-rails"
  s.summary       = "A sanitizer bridge for Rails applications"
  s.license       = "MIT"

  s.require_paths = ["lib"]
  s.files         = `git ls-files`.split("\n")

  s.add_dependency "rails",    ">= 3.0"
  s.add_dependency "sanitize", ">= 3.0"
end
