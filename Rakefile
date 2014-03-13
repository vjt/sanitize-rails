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

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs.push 'test'
  t.test_files = FileList['test/*_test.rb']
  t.warning = true
  t.verbose = true
end

task default: :test
