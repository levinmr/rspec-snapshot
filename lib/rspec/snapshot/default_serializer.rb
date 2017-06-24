# frozen_string_literal: true

require 'awesome_print'

module RSpec
  module Snapshot
    # Serializes values in a human readable way for snapshots using the
    # awesome_print gem
    class DefaultSerializer
      def dump(value)
        value.ai(plain: true, indent: 2)
      end
    end
  end
end
