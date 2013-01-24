# PersistentBlocks

Persist the output of ruby blocks

## Installation

Add this line to your application's Gemfile:

    gem 'persistent_blocks'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install persistent_blocks

## Usage
```ruby
require 'persistent_blocks'
extend PersistentBlocks
		
persist :first_persisted do
	'Here is the first persistent data'
end
    
persist do |first_persisted|	
	puts first_persisted # => 'Here is the first persistent data'
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
