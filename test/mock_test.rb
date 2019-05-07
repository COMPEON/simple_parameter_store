# frozen_string_literal: true

require 'test_helper'

class MockTest < Minitest::Test
  cover 'SimpleParameterStore::Mock*'

  make_my_diffs_pretty!

  def setup
    @mocked_store = Class.new(SimpleParameterStore) do
      prepend SimpleParameterStore::Mock
    end
  end

  def test_works_fine
    @mocked_store.mock = {
      prefix: '/test',
      names: {
        '/foo' => 'bar'
      }
    }

    parameters = @mocked_store.new(
      prefix: '/test',
      names: {
        foo: '/foo'
      }
    )

    assert_equal 'bar', parameters[:foo]
  end

  def test_raises_on_wrong_prefix
    @mocked_store.mock = {
      prefix: '/test',
      names: {
        '/foo' => 'bar'
      }
    }

    error = assert_raises SimpleParameterStore::Mock::MockError do
      @mocked_store.new(
        prefix: '/fail',
        names: {}
      )
    end

    assert_equal <<~MESSAGE, error.message
      Invalid `:prefix`:
        expected: `/test`
         current: `/fail`
    MESSAGE
  end

  def test_raises_on_wrong_decrypt
    @mocked_store.mock = {
      decrypt: false,
      names: {}
    }

    error = assert_raises SimpleParameterStore::Mock::MockError do
      @mocked_store.new(
        decrypt: :do,
        names: {}
      )
    end

    assert_equal <<~MESSAGE, error.message
      Invalid `:decrypt`:
        expected: `false`
         current: `do`
    MESSAGE
  end

  def test_raises_on_wrong_client
    @mocked_store.mock = {
      client: :wrong_client,
      names: {}
    }

    error = assert_raises SimpleParameterStore::Mock::MockError do
      @mocked_store.new(
        names: {}
      )
    end

    assert_equal <<~MESSAGE, error.message
      Invalid `:client`:
        expected: `wrong_client`
         current: `mocked_client`
    MESSAGE
  end

  def test_raises_on_wrong_expires_after
    @mocked_store.mock = {
      expires_after: 1234,
      names: {}
    }

    error = assert_raises SimpleParameterStore::Mock::MockError do
      @mocked_store.new(
        expires_after: 4321,
        names: {}
      )
    end

    assert_equal <<~MESSAGE, error.message
      Invalid `:expires_after`:
        expected: `1234`
         current: `4321`
    MESSAGE
  end

  def test_reset
    @mocked_store.mock = {
      names: {}
    }
    @mocked_store.reset_mock
    assert_nil @mocked_store.mock
  end
end
