# frozen_string_literal: true

require 'pdf/core/text'
require 'prawn/rtl/support/version'
require 'prawn/rtl/connector'

module Prawn
  module Rtl
    # Main module for RTL support functionality.
    module Support
      # Patch module that intercepts Prawn's text rendering to apply RTL transformations.
      #
      # This module is prepended to Prawn::Text::Formatted::Box to automatically
      # process RTL text before rendering. It intercepts the original_text method
      # and applies Arabic letter connection and bidirectional text reordering
      # to any text fragments that contain RTL characters.
      #
      # @example How it works internally
      #   # When Prawn renders text, this patch:
      #   # 1. Intercepts the text fragments
      #   # 2. Applies RTL fixes to each fragment
      #   # 3. Returns the processed fragments for rendering
      module PrawnTextPatch
        # Overrides the original_text method to apply RTL transformations.
        #
        # @return [Array<Hash>] array of text fragments with RTL text properly formatted
        def original_text
          super.map do |h|
            h[:text] = Prawn::Rtl::Connector.fix_rtl(h[:text]) if h.key?(:text)
            h
          end
        end
      end
    end
  end
end

module Prawn
  module Text
    module Formatted
      class Box
        prepend Prawn::Rtl::Support::PrawnTextPatch
      end
    end
  end
end
