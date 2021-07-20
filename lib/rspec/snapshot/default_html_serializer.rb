# frozen_string_literal: true

require "htmlbeautifier"

module RSpec
  module Snapshot
    class DefaultHtmlSerializer
      def dump(value)
        HtmlBeautifier.beautify(value)
      end
    end
  end
end
