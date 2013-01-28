# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'persistent_blocks/version'

Gem::Specification.new do |gem|
  gem.name          = "persistent_blocks"
  gem.version       = PersistentBlocks::VERSION
  gem.authors       = ["Morris Feldman"]
  gem.email         = ["morrifeldman@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = "Persists the output of Ruby blocks"
  gem.homepage      = "http://github.com/morrifeldman/persistent_blocks"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_runtime_dependency 'rake'
  gem.add_development_dependency 'debugger'
  gem.description       = <<desc
  This gem provides a rake extension to wrap blocks of ruby code so
  that the output of the block is persisted using marshal.  Blocks
  with persisted data will not be rerun and their data is available to
  subsequent blocks which can themselves generate persistent data.
  This allow a very simple and robust pipeline to be constructed in
  within a regular rakefile.   
desc
end
