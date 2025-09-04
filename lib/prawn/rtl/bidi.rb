# frozen_string_literal: true

require 'rbconfig'
require 'ffi'

module Prawn
  module Rtl
    # FFI BiDi wrapper for Unicode Bidirectional Algorithm support
    #
    # This module provides direct FFI bindings to ICU's ubidi functions
    # for bidirectional text processing.
    module Bidi
      extend FFI::Library

      class BiDiError < StandardError; end

      # Detect platform
      def self.platform
        os = RbConfig::CONFIG['host_os']
        case os
        when /darwin/
          :osx
        when /linux/
          :linux
        when /bsd/
          :bsd
        when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
          :windows
        else
          :linux
        end
      end

      # Search paths for ICU libraries
      def self.search_paths
        @search_paths ||=
          if ENV['ICU_LIB_PATH']
            [ENV['ICU_LIB_PATH']]
          elsif FFI::Platform::IS_WINDOWS
            ENV['PATH'].split(File::PATH_SEPARATOR)
          else
            [
              '/usr/local/{lib64,lib}',
              '/opt/local/{lib64,lib}',
              '/opt/homebrew/{lib64,lib}',
              '/usr/{lib64,lib}'
            ] + Dir['/usr/lib/*-linux-gnu'] + Dir['/lib/*-linux-gnu']
          end
      end

      # Find ICU library files
      def self.find_icu_lib
        candidates = []
        lib_name = 'icuuc'

        search_paths.each do |path|
          Dir.glob(File.expand_path(path)).each do |dir|
            # Try versioned libraries first (newer to older)
            # ICU versions from 4.0 (2009) to potential future versions
            90.downto(4).each do |version|
              case platform
              when :osx
                candidates << File.join(dir, "lib#{lib_name}.#{version}.dylib")
                candidates << File.join(dir, "lib#{lib_name}.dylib")
              when :windows
                candidates << File.join(dir, "#{lib_name}#{version}.dll")
                candidates << File.join(dir, "#{lib_name}.dll")
              else
                candidates << File.join(dir, "lib#{lib_name}.so.#{version}")
                candidates << File.join(dir, "lib#{lib_name}.so")
              end
            end
          end
        end

        # Find the first existing library
        found = candidates.find { |path| File.exist?(path) }
        found || ["lib#{lib_name}.so", "lib#{lib_name}.dylib", "#{lib_name}.dll", lib_name]
      end

      # Load the library
      ffi_lib find_icu_lib

      # Detect ICU version suffix by checking for a known function
      def self.detect_icu_suffix
        @detect_icu_suffix ||= begin
          # Try common suffixes from newer to older versions
          # Some versions use _4_2 format, others use _42 format
          suffixes = [''] + 90.downto(4).flat_map { |v| ["_#{v}", "_#{v / 10}_#{v % 10}"] }

          # Find suffix by checking if ubidi_open function exists
          suffix = suffixes.find do |s|
            # Try to find the function
            func_name = :"ubidi_open#{s}"
            ffi_libraries.any? do |lib|
              lib.find_function(func_name.to_s)
            end
          rescue StandardError
            false
          end

          suffix || ''
        end
      end

      # Helper to attach function with detected suffix
      def self.attach_icu_function(ruby_name, icu_name, args, return_type)
        suffixed_name = "#{icu_name}#{detect_icu_suffix}"
        attach_function ruby_name, suffixed_name.to_sym, args, return_type
      end

      # Constants from ubidi.h
      UBIDI_DEFAULT_LTR = 0xfe
      UBIDI_DEFAULT_RTL = 0xff
      UBIDI_LTR = 0
      UBIDI_RTL = 1
      UBIDI_MIXED = 2
      UBIDI_NEUTRAL = 3

      # Reorder options
      UBIDI_DO_MIRRORING = 2
      UBIDI_OUTPUT_REVERSE = 16

      # Attach ICU functions with version detection
      attach_icu_function :ubidi_open, 'ubidi_open', [], :pointer
      attach_icu_function :ubidi_close, 'ubidi_close', [:pointer], :void
      attach_icu_function :ubidi_setPara, 'ubidi_setPara', %i[pointer pointer int32 uint8 pointer pointer], :void
      attach_icu_function :ubidi_getDirection, 'ubidi_getDirection', [:pointer], :int
      attach_icu_function :ubidi_getLength, 'ubidi_getLength', [:pointer], :int32
      attach_icu_function :ubidi_writeReordered, 'ubidi_writeReordered', %i[pointer pointer int32 uint16 pointer],
                          :int32
      attach_icu_function :ubidi_countRuns, 'ubidi_countRuns', %i[pointer pointer], :int32

      # Reorders text according to the Unicode Bidirectional Algorithm
      #
      # @param text [String] the text to reorder
      # @param direction [Symbol] :ltr, :rtl, or :auto (default)
      # @return [String] the visually reordered text
      def self.reorder(text, direction: :auto)
        return text if text.nil? || text.empty?

        # Convert direction to ubidi constant
        para_level =
          case direction
          when :ltr then UBIDI_LTR
          when :rtl then UBIDI_RTL
          else UBIDI_DEFAULT_LTR
          end

        bidi = nil
        begin
          # Open BiDi object
          bidi = ubidi_open
          raise BiDiError, 'Failed to create BiDi object' if bidi.null?

          # Convert string to UTF-16 for ICU
          utf16_text = text.encode('UTF-16LE')
          text_length = utf16_text.bytesize / 2

          # Create buffer for UTF-16 string
          text_buffer = FFI::MemoryPointer.new(:uint16, text_length + 1)
          text_buffer.put_bytes(0, utf16_text)

          # Error status
          status = FFI::MemoryPointer.new(:int32)
          status.put_int32(0, 0)

          # Set paragraph
          ubidi_setPara(bidi, text_buffer, text_length, para_level, nil, status)

          error_code = status.get_int32(0)
          raise BiDiError, "ubidi_setPara failed with error code: #{error_code}" if error_code.positive?

          # Get required size for output
          output_length = text_length * 2
          output_buffer = FFI::MemoryPointer.new(:uint16, output_length)

          # Write reordered text
          written = ubidi_writeReordered(bidi, output_buffer, output_length, UBIDI_DO_MIRRORING, status)

          error_code = status.get_int32(0)
          raise BiDiError, "ubidi_writeReordered failed with error code: #{error_code}" if error_code.positive?

          # Convert back from UTF-16 to UTF-8
          result_bytes = output_buffer.get_bytes(0, written * 2)
          result_bytes.force_encoding('UTF-16LE').encode('UTF-8')
        ensure
          ubidi_close(bidi) if bidi && !bidi.null?
        end
      end

      # Checks if a string contains RTL characters
      #
      # @param text [String] the text to check
      # @return [Boolean] true if the text contains RTL characters
      def self.contains_rtl?(text)
        return false if text.nil? || text.empty?

        bidi = nil
        begin
          bidi = ubidi_open
          return false if bidi.null?

          utf16_text = text.encode('UTF-16LE')
          text_length = utf16_text.bytesize / 2

          text_buffer = FFI::MemoryPointer.new(:uint16, text_length + 1)
          text_buffer.put_bytes(0, utf16_text)

          status = FFI::MemoryPointer.new(:int32)
          status.put_int32(0, 0)

          ubidi_setPara(bidi, text_buffer, text_length, UBIDI_DEFAULT_LTR, nil, status)

          return false if status.get_int32(0).positive?

          direction = ubidi_getDirection(bidi)
          [UBIDI_RTL, UBIDI_MIXED].include?(direction)
        ensure
          ubidi_close(bidi) if bidi && !bidi.null?
        end
      end
    end
  end
end
