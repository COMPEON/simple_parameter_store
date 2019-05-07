# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'simple_parameter_store'
require 'simple_parameter_store/mock'

require 'minitest/autorun'
require 'minitest/mock'

require 'mutant/minitest/coverage'
