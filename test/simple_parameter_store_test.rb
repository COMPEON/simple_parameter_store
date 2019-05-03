# frozen_string_literal: true

require 'test_helper'
require 'aws-sdk-ssm'

class SimpleParameterStoreTest < Minitest::Test
  make_my_diffs_pretty!

  def setup
    Aws.config[:ssm] = {
      stub_responses: {
        get_parameters: {
          parameters: [
            { name: '/prefix/foo', value: 'foo' },
            { name: '/prefix/bar', value: '123' }
          ],
          invalid_parameters: []
        }
      }
    }
  end

  def test_that_it_has_a_version_number
    refute_nil ::SimpleParameterStore::VERSION
  end

  def test_mock
    client = Aws::SSM::Client.new
    result = client.get_parameters(names: ['/prefix/foo', '/prefix/bar'])

    parameter = result.parameters[0]
    assert_instance_of Aws::SSM::Types::Parameter, parameter
    assert_equal '/prefix/foo', parameter.name
    assert_equal 'foo', parameter.value

    parameter = result.parameters[1]
    assert_instance_of Aws::SSM::Types::Parameter, parameter
    assert_equal '/prefix/bar', parameter.name
    assert_equal '123', parameter.value

    assert_equal [], result.invalid_parameters
  end

  def test_required_arguments
    error = assert_raises ArgumentError do
      SimpleParameterStore.new
    end
    assert_equal 'missing keyword: names', error.message
  end

  def test_default_arguments
    store = SimpleParameterStore.new(names: { foo: '/prefix/foo', bar: '/prefix/bar' })

    assert_instance_of Aws::SSM::Client, store.client
    assert_equal true, store.decrypt
    assert_nil store.prefix
    assert_nil store.expires_after
  end

  def test_arguments
    client = Aws::SSM::Client.new
    store = SimpleParameterStore.new(
      client: client,
      decrypt: false,
      prefix: '/prefix',
      expires_after: 123,
      names: { foo: '/foo', bar: '/bar' }
    )

    assert_same client, store.client
    assert_equal false, store.decrypt
    assert_equal '/prefix', store.prefix
    assert_equal 123, store.expires_after
  end

  def test_refresing
    store = Time.stub :now, Time.at(0) do
      SimpleParameterStore.new(names: { foo: '/prefix/foo', bar: '/prefix/bar' }, expires_after: 1)
    end
    assert_equal Time.at(1), store.expires_at

    Time.stub :now, Time.at(1) do
      store.refresh_if_needed
    end
    assert_equal Time.at(1), store.expires_at

    Time.stub :now, Time.at(2) do
      store.refresh_if_needed
    end
    assert_equal Time.at(3), store.expires_at

    store.instance_variable_set :@expires_at, Time.at(1)
    Time.stub :now, Time.at(1) do
      store.refresh
    end
    assert_equal Time.at(2), store.expires_at

    store.instance_variable_set :@expires_at, Time.at(1)
    Time.stub :now, Time.at(1) do
      store[:foo]
    end
    assert_equal Time.at(1), store.expires_at

    Time.stub :now, Time.at(2) do
      store[:foo]
    end
    assert_equal Time.at(3), store.expires_at
  end

  def test_casting
    store = SimpleParameterStore.new(names: { foo: '/prefix/foo', bar: ['/prefix/bar', :to_i.to_proc] })

    assert_equal 'foo', store[:foo]
    assert_equal 123, store[:bar]
  end

  def test_error_on_invalid_parameters
    Aws.config[:ssm].dig(:stub_responses, :get_parameters, :invalid_parameters).push 'missing_key'

    error = assert_raises SimpleParameterStore::SSMKeyError do
      SimpleParameterStore.new(names: { missing: 'missing_key' })
    end
    assert_kind_of KeyError, error
  end

  def test_error_on_missing_key
    store = SimpleParameterStore.new(names: { foo: '/prefix/foo', bar: '/prefix/bar' })

    assert_raises KeyError do
      store[:baz]
    end
  end

  def test_get_parameters_args
    result = Minitest::Mock.new
    result.expect(:invalid_parameters, [])
    result.expect(:parameters, [])

    client = Minitest::Mock.new
    client.expect(:get_parameters, result, [names: ['/prefix/foo', '/prefix/bar'], with_decryption: false])

    SimpleParameterStore.new(client: client, decrypt: false, names: { foo: '/prefix/foo', bar: '/prefix/bar' })

    assert_mock client
  end
end
