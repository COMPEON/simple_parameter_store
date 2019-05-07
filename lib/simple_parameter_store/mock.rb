# frozen_string_literal: true

class SimpleParameterStore
  module Mock
    class MockError < StandardError; end

    class Parameter
      attr_reader :name, :value
      def initialize(name, value)
        @name = name
        @value = value
      end
    end

    def self.prepended(base)
      base.extend ClassMethods
    end

    private

    def verify
      %i[prefix decrypt expires_after client].each do |key|
        current_value = instance_variable_get("@#{key}")
        expected_value = self.class.mock.fetch(key)
        raise MockError, <<~ERROR unless current_value.equal?(expected_value)
          Invalid `:#{key}`:
            expected: `#{expected_value}`
             current: `#{current_value}`
        ERROR
      end
    end

    def fetch
      verify

      self.class.mock.fetch(:cache)
    end

    def build_client
      :mocked_client
    end

    module ClassMethods
      attr_reader :mock

      def mock=(names:, client: nil, prefix: nil, decrypt: true, expires_after: nil)
        @mock = {
          cache: names.map { |(key, value)| Parameter.new("#{prefix}#{key}", value) },
          prefix: prefix,
          decrypt: decrypt,
          expires_after: expires_after,
          client: (client || :mocked_client)
        }
      end

      def reset_mock
        @mock = nil
      end
    end
  end
end
