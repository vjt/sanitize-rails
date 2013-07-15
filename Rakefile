begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'Sanitize-Rails'
  rdoc.options << '--line-numbers'

  rdoc.rdoc_files.include 'README.md'
  rdoc.rdoc_files.include 'lib/**/*.rb'
end

Bundler::GemHelper.install_tasks

desc 'Will someone help write tests?'
task :default do
  puts
  puts 'Can you help in writing tests? Please do :-)'
  puts
end
