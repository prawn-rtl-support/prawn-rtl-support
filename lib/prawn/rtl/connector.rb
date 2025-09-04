# frozen_string_literal: true

require_relative 'connector/logic'
require_relative 'bidi'

module Prawn
  module Rtl
    # Provides bidirectional text support and Arabic letter connection for Prawn PDF generation.
    #
    # This module handles RTL (Right-to-Left) text processing by:
    # - Connecting Arabic script letters according to their contextual forms
    # - Reordering text using the Unicode Bidirectional Algorithm
    # - Supporting multiple RTL languages (Arabic, Hebrew, Persian, Urdu, etc.)
    # - Handling mixed LTR/RTL text properly
    #
    # @example Fix Arabic text for PDF rendering
    #   text = "مرحبا بالعالم"
    #   fixed_text = Prawn::Rtl::Connector.fix_rtl(text)
    #
    # @example Fix Hebrew text for PDF rendering
    #   text = "שלום עולם"
    #   fixed_text = Prawn::Rtl::Connector.fix_rtl(text)
    #
    # @example Fix mixed LTR/RTL text
    #   text = "Hello مرحبا World"
    #   fixed_text = Prawn::Rtl::Connector.fix_rtl(text)
    module Connector
      # Connects Arabic letters according to their contextual forms.
      #
      # @param string [String] the text containing Arabic letters to connect
      # @return [String] the text with properly connected Arabic letters
      def self.connect(string)
        Prawn::Rtl::Connector::Logic.transform(string)
      end

      # Fixes RTL text by connecting Arabic letters and reordering for visual display.
      #
      # This is the main entry point for processing RTL text. It detects if the text
      # contains RTL characters and applies both letter connection and bidirectional
      # reordering if needed.
      #
      # @param string [String] the text to process
      # @return [String] the processed text ready for PDF rendering
      def self.fix_rtl(string)
        return string unless include_rtl?(string)

        reorder(connect(string))
      end

      # Reorders text according to the Unicode Bidirectional Algorithm.
      #
      # Uses ICU's BiDi implementation via FFI to visually reorder mixed
      # LTR/RTL text for correct display.
      #
      # @param string [String] the text to reorder
      # @return [String] the visually reordered text
      def self.reorder(string)
        Bidi.reorder(string, direction: :rtl)
      end

      # Checks if a string contains RTL (Right-to-Left) characters.
      #
      # @param string [String] the text to check
      # @return [Boolean] true if the text contains RTL characters, false otherwise
      def self.include_rtl?(string)
        Bidi.contains_rtl?(string)
      end
    end
  end
end
