# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_parameter_store/version'

Gem::Specification.new do |spec|
  spec.name          = 'simple_parameter_store'
  spec.version       = SimpleParameterStore::VERSION
  spec.authors       = ['Timo Schilling']
  spec.email         = ['timo@schilling.io']

  spec.summary       = 'Simple abstraction of AWS SSM Parameter Store.'
  spec.description   = 'Simple abstraction of AWS SSM Parameter Store.'
  spec.homepage      = 'https://github.com/COMPEON/simple_parameter_store'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk-ssm'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'mutant'
  spec.add_development_dependency 'mutant-minitest'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
end
