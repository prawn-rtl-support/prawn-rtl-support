# frozen_string_literal: true

require 'prawn/rtl/connector/logic'
require 'twitter_cldr'

module Prawn
  module Rtl
    module Connector
      def self.connect(string)
        Prawn::Rtl::Connector::Logic.transform(string)
      end

      def self.fix_rtl(string)
        return string unless include_rtl?(string)

        reorder(connect(string))
      end

      def self.reorder(string)
        TwitterCldr::Shared::Bidi
          .from_string(string, direction: :RTL)
          .reorder_visually!
          .to_s
      end

      def self.include_rtl?(string)
        TwitterCldr::Shared::Bidi
          .from_string(string)
          .types
          .include?(:R)
      end
    end
  end
end
