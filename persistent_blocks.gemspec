Gem::Specification.new do |gem|
  gem.name          = "persistent_blocks"
  gem.version       = "0.1.0"
  gem.author        = "Morris Feldman"
  gem.email         = "morrifeldman@gmail.com"
  gem.summary       = "Persists the output of Ruby blocks"
  gem.homepage      = "http://github.com/morrifeldman/persistent_blocks"

  gem.files         = `git ls-files`.split($/)
  
  gem.add_runtime_dependency 'rake'

  gem.description       = <<EODESC
  This gem provides a rake extension to wrap blocks of ruby code so
  that the output of the block is persisted using marshal.  Blocks
  with persisted data will not be rerun and their data is available to
  subsequent blocks which can themselves generate persistent data.
  This allow a very simple and robust pipeline to be constructed in
  within a regular rakefile.   
EODESC
  
end
