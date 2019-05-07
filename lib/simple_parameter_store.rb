# frozen_string_literal: true

require 'simple_parameter_store/mock'
require 'simple_parameter_store/version'
require 'aws-sdk-ssm'

class SimpleParameterStore
  class SSMKeyError < KeyError; end

  def initialize(names:, client: nil, prefix: nil, decrypt: true, expires_after: nil)
    @client = client || build_client
    @prefix = prefix
    @decrypt = decrypt
    @expires_after = expires_after

    @mappings = {}
    @casters = {}
    @cache = {}

    prepare(names)
    refresh
  end

  attr_reader :client, :prefix, :decrypt, :expires_after, :expires_at

  def refresh
    fetch.each_pair do |name, value|
      key, = @mappings.rassoc(name)
      caster = @casters.fetch(key)
      value = caster.call(value)
      @cache[key] = value
    end

    @expires_at = Time.now + expires_after if expires_after
  end

  def refresh_if_needed
    refresh if expired?
  end

  def expired?
    expires_after && expires_at < Time.now
  end

  def [](key)
    refresh_if_needed
    @cache.fetch(key)
  end

  private

  def fetch
    result = client.get_parameters(names: @mappings.values, with_decryption: decrypt)
    raise SSMKeyError, "Missing keys: `#{result.invalid_parameters}`" if result.invalid_parameters.any?

    result.parameters.map { |parameter| [parameter.name, parameter.value] }.to_h
  end

  def prepare(names)
    names.each_pair do |key, (name, caster)|
      @mappings[key] = "#{prefix}#{name}"
      @casters[key] = caster || :itself.to_proc
    end
  end

  def build_client
    Aws::SSM::Client.new
  end
end
