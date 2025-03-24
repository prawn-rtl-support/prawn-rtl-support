# frozen_string_literal: true

require 'prawn/rtl/connector/logic'
require 'twitter_cldr'

module Prawn
  module Rtl
    module Connector
      extend self

      # Unicode ranges for common RTL scripts:
      # Arabic (0600-06FF), Hebrew (0590-05FF), Syriac (0700-074F),
      # Arabic Supplement (0750-077F), Thaana (0780-07BF),
      # NKo (07C0-07FF), Samaritan (0800-083F), Mandaic (0840-085F),
      # other extended RTL characters, and Bidi control characters.
      RTL_REGEX = /[\u0590-\u08FF\uFB1D-\uFDFF\uFE70-\uFEFF\u200F\u202A-\u202E\u2066-\u2069]/

      def include_rtl?(string)
        string&.match?(RTL_REGEX)
      end

      def include_arabic?(string)
        string&.match?(/\p{Arabic}/)
      end

      # Slow version
      def include_rtl_bidi?(string)
        return false if !string || string.empty?
        TwitterCldr::Shared::Bidi.from_string(string)
                                 .types
                                 .include?(:R)
      end

      def connect_arabic(string)
        Prawn::Rtl::Connector::Logic.transform(string)
      end

      def fix_rtl(string)
        return string unless include_rtl?(string)
        reorder(string)
      end

      def reorder(string)
        TwitterCldr::Shared::Bidi.from_string(string, direction: :RTL)
                                 .reorder_visually!
                                 .to_s
      end

      # Given an array of string fragments, concatenate them
      # and reorder them visually, while returning a map of
      # the original string index in the reordered string.
      #
      # TODO: The markers themselves may interfere with the Bidi
      # reordering algorithm. Consider using a different approach.
      def reorder_fragments(array_of_strings)
        array_of_strings = clean_trailing_strings(array_of_strings.dup)

        return [[0, '']] if array_of_strings.size == 0
        return [[0, reorder(array_of_strings.first)]] if array_of_strings.size == 1

        # TODO: PUA usage here may break FontAwesome and other
        # icon fonts. Could potentially use 0xF000 as the starting marker.
        # followed by the specific marker, but that may be corrupted by reordering.
        marker_start = 0xF000 # Private Use Area starting code point
        marker_end   = 0xF8FF # Private Use Area ending code point
        marker_range = marker_end - marker_start
        marked = +''

        # Abandoned approach:
        # lro = "\u202D"
        # pdf = "\u202C"
        # foo = "\uF000" # Private Use Area starting code point

        # Concatenates the string with markers around each fragment.
        array_of_strings.each_with_index do |string, i|
          i = marker_range if i > marker_range
          marker = (marker_start + i).chr(::Encoding::UTF_8)
          string = string.gsub(/[\uF000-\uF8FF]/, '')
          next if string.empty?
          marked << marker << string << marker
        end

        marked = reorder(marked)

        # Iterate over the marked string, generating pairs of
        # index and reordered text fragments.
        index = nil
        marked.split(/([\uF000-\uF8FF])/).each_with_object([]) do |segment, output|
          ord = segment.size == 1 && segment.first.ord
          if ord && ord >= marker_start && ord <= marker_end
            index = ord - marker_start
          else
            output << [index, segment]
          end
        end
      end

      private

      def clean_trailing_strings(array)
        # Remove trailing blank strings
        while !array.empty? && array.last.strip.empty?
          array.pop
        end

        # Remove trailing whitespace from the last string
        array[-1] = array.last.rstrip if !array.empty?

        array
      end
    end
  end
end
