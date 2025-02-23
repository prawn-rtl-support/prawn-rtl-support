# frozen_string_literal: true

require 'pdf/core/text'
require 'prawn/rtl/support/version'
require 'prawn/rtl/connector'

module Prawn
  module Rtl
    module Support
      module PrawnTextPatch
        def original_text
          super.map do |h|
            if Prawn::Rtl::Connector.include_arabic?(h[:text])
              h[:text] = Prawn::Rtl::Connector.connect_arabic(h[:text])
            end
            h
          end
        end
      end
    end
  end
end

::Prawn::Text::Formatted::Box.prepend(Prawn::Rtl::Support::PrawnTextPatch)

module Prawn
  module Rtl
    module Support
      module PrawnArrangerPatch
        def finalize_line
          if @consumed.any? { |h| Prawn::Rtl::Connector.include_rtl?(h[:text]) }
            finalize_line_with_rtl
          else
            super
          end
        end

        private

        # Finish laying out current line.
        #
        # @return [void]
        def finalize_line_with_rtl
          @finalized = true
          omit_trailing_whitespace_from_line_width

          # TODO: This next section is a bit of a hack. Currently, the
          # #reorder_fragments method does not work perfectly and can create artifacts.
          # Therefore,
          # TODO: This needs font support
          consumed_chunks = @consumed.chunk do |hash|
            key = hash[:styles]
            key&.empty? ? 0 : key
          end.filter_map do |_, group|
            text = group.map { |h| h[:text] }.join
            text.gsub!(/[\r\n]/, '')
            next if text.empty?
            state = group.first&.reject { |k, _| k == :text } || {} # ensure we have any base key-values we need
            state = group.each_with_object(state) { |item, merged| merged.merge!(item.reject { |k, v| k == :text || !v || (v.respond_to?(:empty?) && v.empty?) }) }
            [text, state]
          end

          # consumed_chunks = @consumed.filter_map do |hash|
          #   text = hash[:text].gsub(/[\r\n]/, '')
          #   next if text.empty?
          #   state = hash.reject { |k, _| k == :text }
          #   [text, state]
          # end

          Prawn::Rtl::Connector.reorder_fragments(consumed_chunks.map(&:first)).each do |index, text|
            rtl_flush_fragment(text, consumed_chunks[index || 0]&.last)
          end
        end

        def rtl_flush_fragment(text, state)
          return unless text && !text.empty?

          # TODO: Setting :direction here currently does nothing.
          # It should affect text alignment.
          state[:direction] ||= :rtl if Prawn::Rtl::Connector.include_rtl?(text)

          fragment = Prawn::Text::Formatted::Fragment.new(text, state, @document)
          @fragments << fragment
          self.fragment_measurements = fragment
          self.line_measurement_maximums = fragment
        end
      end
    end
  end
end

::Prawn::Text::Formatted::Arranger.prepend(Prawn::Rtl::Support::PrawnArrangerPatch)

module Prawn
  module Rtl
    module Support
      module PrawnFragmentPatch

        # This patch is needed to undo the simple reversing (non-Bidi)
        # of characters that Prawn does using RTL.
        def process_text(text)
          return super unless direction == :rtl

          # This is the original code
          string = strip_zero_width_spaces(text)
          if exclude_trailing_white_space?
            string = string.rstrip
            if soft_hyphens_need_processing?(string)
              string = process_soft_hyphens(string[0..-2]) + string[-1..]
            end
          elsif soft_hyphens_need_processing?(string)
            string = process_soft_hyphens(string)
          end

          string

          # This next block is removed
          # if direction == :rtl
          #   string.reverse
          # else
          #   string
          # end
        end
      end
    end
  end
end

::Prawn::Text::Formatted::Fragment.prepend(Prawn::Rtl::Support::PrawnFragmentPatch)
