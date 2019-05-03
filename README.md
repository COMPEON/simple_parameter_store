# SimpleParameterStore

`SimpleParameterStore` gives you an nice abstraction over the AWS SSM Parameter Store.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_parameter_store'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_parameter_store

## Usage

```ruby
require 'simple_parameter_store'

parameters = SimpleParameterStore.new(
  client: Aws::SSM::Client.new,                           # optional, default: `Aws::SSM::Client.new`, can be used to set custom args for the SSM client
  prefix: "/#{ENV['ENVIRONMENT']}",                       # optional, default: `nil`, can be used to prefix all parameter names with `/production`
  expires_after: 3600,                                    # optional, default: `nil`, time in seconds after the store will be refreshed
  decryp: true,                                           # optional, default: `true`, enable/disable automatic parameter decryption
  names: {                                                # requires, hash with mapping of parameter names, the key will be used for the store index
    foo: '/bar',                                          # aliased the key `/bar` (if prefix is `nil`) under the `:foo` in the store
    max: ['max', :to_i.to_proc],                          # the value can be an array with the key as first and a caster as second value,
    key: ['private_key', OpenSSL::PKey::RSA.method(:new)] # the caster must be respond to `call` and return the converted value
  }
)

parameters[:foo] # => `'bar'`
parameters[:max] # => `123`
parameters[:key].class # => OpenSSL::PKey::RSA

parameters.refresh           # forces an store refresh
parameters.refresh_if_needed # refreshes the store is expired
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/COMPEON/simple_parameter_store.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
