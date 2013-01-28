require "rake/testtask"
require_relative "lib/persistent_blocks/version"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

task :default => 'test'

task :build do
  puts `gem build persistent_blocks.gemspec`
end

task :install do
  puts `gem install persistent_blocks-#{PersistentBlocks::VERSION}.gem`
end
