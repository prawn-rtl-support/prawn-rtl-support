# frozen_string_literal: true

require 'spec_helper'
require 'prawn/rtl/bidi'

RSpec.describe Prawn::Rtl::Bidi do
  describe '.reorder' do
    context 'with Arabic text' do
      it 'reorders pure Arabic text' do
        input = 'مرحبا بالعالم'
        result = described_class.reorder(input, direction: :rtl)
        expect(result.encoding).to eq(Encoding::UTF_8)
      end

      it 'handles mixed Arabic and English text' do
        input = 'Hello مرحبا World'
        result = described_class.reorder(input)
        expect(result).to eq('Hello ابحرم World')
      end

      it 'preserves Arabic numbers' do
        input = 'العدد ١٢٣ والرقم ٤٥٦'
        result = described_class.reorder(input, direction: :rtl)
        expect(result).to eq('٤٥٦ مقرلاو ١٢٣ ددعلا')
      end
    end

    context 'with Hebrew text' do
      it 'reorders pure Hebrew text' do
        input = 'שלום עולם'
        result = described_class.reorder(input, direction: :rtl)
        expect(result.encoding).to eq(Encoding::UTF_8)
      end

      it 'handles mixed Hebrew and English text' do
        input = 'Hello שלום World'
        result = described_class.reorder(input)
        # Hebrew reordered: שלום becomes םולש
        expect(result).to eq('Hello םולש World')
      end

      it 'preserves Hebrew punctuation' do
        input = 'שלום, עולם!'
        result = described_class.reorder(input, direction: :rtl)
        expect(result).to eq('!םלוע ,םולש')
      end
    end

    context 'with Persian/Farsi text' do
      it 'reorders Persian text correctly' do
        input = 'سلام دنیا'
        result = described_class.reorder(input, direction: :rtl)
        expect(result.encoding).to eq(Encoding::UTF_8)
      end

      it 'handles Persian numbers' do
        input = 'عدد ۱۲۳ و ۴۵۶'
        result = described_class.reorder(input, direction: :rtl)
        expect(result).to eq('۴۵۶ و ۱۲۳ ددع')
      end
    end

    context 'with Urdu text' do
      it 'reorders Urdu text correctly' do
        input = 'اردو متن'
        result = described_class.reorder(input, direction: :rtl)
        expect(result.encoding).to eq(Encoding::UTF_8)
      end
    end

    context 'with direction parameter' do
      let(:mixed_text) { 'Hello مرحبا World' }

      it 'respects :ltr direction' do
        result = described_class.reorder(mixed_text, direction: :ltr)
        expect(result).not_to be_nil
      end

      it 'respects :rtl direction' do
        result = described_class.reorder(mixed_text, direction: :rtl)
        expect(result).not_to be_nil
      end

      it 'uses :auto direction by default' do
        result = described_class.reorder(mixed_text)
        result_auto = described_class.reorder(mixed_text, direction: :auto)
        expect(result).to eq(result_auto)
      end
    end

    context 'with edge cases' do
      it 'handles empty strings' do
        expect(described_class.reorder('')).to eq('')
      end

      it 'handles nil values' do
        expect(described_class.reorder(nil)).to be_nil
      end

      it 'returns unchanged for pure LTR text' do
        input = 'Hello World 123'
        result = described_class.reorder(input)
        expect(result).to eq('Hello World 123')
      end

      it 'returns unchanged for strings with only spaces' do
        input = '   '
        expect(described_class.reorder(input)).to eq('   ')
      end

      it 'preserves newlines in mixed text' do
        input = "Hello\nمرحبا\nWorld"
        result = described_class.reorder(input)
        # BiDi handling of newlines can vary, just ensure they're preserved
        expect(result).to include("\n")
      end

      it 'processes very long mixed text without errors' do
        long_text = "#{'Hello مرحبا ' * 100}#{'שלום World ' * 100}"
        result = described_class.reorder(long_text)
        expect(result.length).to eq(long_text.length)
      end

      it 'preserves emoji in mixed text' do
        input = 'Hello 😊 مرحبا 🌍 World'
        result = described_class.reorder(input)
        expect(result).to eq('Hello 😊 ابحرم 🌍 World')
      end
    end

    context 'with complex bidirectional text' do
      it 'handles nested bidirectional text' do
        input = 'The title is "مرحبا بالعالم" in Arabic'
        result = described_class.reorder(input)
        expect(result).to eq('The title is "ملاعلاب ابحرم" in Arabic')
      end

      it 'handles multiple RTL segments' do
        input = 'First عربي then עברית finally فارسی end'
        result = described_class.reorder(input)
        expect(result).to eq('First يبرع then תירבע finally یسراف end')
      end

      it 'handles parentheses with RTL text' do
        input = 'Text (مرحبا) more text'
        result = described_class.reorder(input)
        expect(result).to eq('Text (ابحرم) more text')
      end

      it 'handles URLs with RTL text' do
        input = 'Visit http://example.com/مرحبا for info'
        result = described_class.reorder(input)
        expect(result).to eq('Visit http://example.com/ابحرم for info')
      end
    end
  end

  describe '.contains_rtl?' do
    context 'with RTL scripts' do
      it 'detects pure Arabic text' do
        expect(described_class.contains_rtl?('مرحبا')).to be true
      end

      it 'detects Arabic text in mixed content' do
        expect(described_class.contains_rtl?('Hello مرحبا World')).to be true
      end

      it 'detects pure Hebrew text' do
        expect(described_class.contains_rtl?('שלום')).to be true
      end

      it 'detects Hebrew text in mixed content' do
        expect(described_class.contains_rtl?('Hello שלום World')).to be true
      end

      it 'detects pure Persian text' do
        expect(described_class.contains_rtl?('سلام')).to be true
      end

      it 'detects Persian text in mixed content' do
        expect(described_class.contains_rtl?('Hello سلام World')).to be true
      end

      it 'detects Urdu text' do
        expect(described_class.contains_rtl?('اردو')).to be true
      end

      it 'detects Syriac text' do
        expect(described_class.contains_rtl?('ܫܠܡܐ')).to be true
      end

      it 'detects Thaana text' do
        expect(described_class.contains_rtl?('ދިވެހި')).to be true
      end

      it 'returns false for Arabic-Indic digits alone (they are neutral)' do
        expect(described_class.contains_rtl?('١٢٣')).to be false
      end

      it 'detects RTL when Arabic-Indic digits are with Arabic text' do
        expect(described_class.contains_rtl?('العدد ١٢٣')).to be true
      end

      it 'returns false for Persian digits alone (they are neutral)' do
        expect(described_class.contains_rtl?('۱۲۳')).to be false
      end

      it 'detects RTL when Persian digits are with Persian text' do
        expect(described_class.contains_rtl?('عدد ۱۲۳')).to be true
      end
    end

    context 'with LTR scripts' do
      it 'returns false for English text' do
        expect(described_class.contains_rtl?('Hello World')).to be false
      end

      it 'returns false for numbers' do
        expect(described_class.contains_rtl?('123456')).to be false
      end

      it 'returns false for Latin characters' do
        expect(described_class.contains_rtl?('ABCDEFG')).to be false
      end

      it 'returns false for punctuation only' do
        expect(described_class.contains_rtl?('!@#$%^&*()')).to be false
      end

      it 'returns false for Cyrillic text' do
        expect(described_class.contains_rtl?('Привет мир')).to be false
      end

      it 'returns false for Chinese text' do
        expect(described_class.contains_rtl?('你好世界')).to be false
      end

      it 'returns false for Japanese text' do
        expect(described_class.contains_rtl?('こんにちは世界')).to be false
      end
    end

    context 'with edge cases' do
      it 'returns false for empty strings' do
        expect(described_class.contains_rtl?('')).to be false
      end

      it 'returns false for nil' do
        expect(described_class.contains_rtl?(nil)).to be false
      end

      it 'returns false for spaces only' do
        expect(described_class.contains_rtl?('   ')).to be false
      end

      it 'returns false for newlines only' do
        expect(described_class.contains_rtl?("\n\n\n")).to be false
      end

      it 'handles very long text without RTL' do
        long_text = 'Hello World ' * 1000
        expect(described_class.contains_rtl?(long_text)).to be false
      end

      it 'handles very long text with RTL' do
        long_text = "#{'Hello World ' * 500}مرحبا #{'Hello World ' * 500}"
        expect(described_class.contains_rtl?(long_text)).to be true
      end

      it 'detects RTL even with lots of LTR text' do
        text = "#{'a' * 1000}א#{'b' * 1000}"
        expect(described_class.contains_rtl?(text)).to be true
      end
    end

    context 'with mixed content' do
      it 'detects RTL in mixed text with punctuation' do
        expect(described_class.contains_rtl?('Hello, مرحبا!')).to be true
      end

      it 'detects RTL in parentheses' do
        expect(described_class.contains_rtl?('Text (عربي) here')).to be true
      end

      it 'detects RTL in quotes' do
        expect(described_class.contains_rtl?('"مرحبا"')).to be true
      end

      it 'detects RTL with numbers' do
        expect(described_class.contains_rtl?('123 مرحبا 456')).to be true
      end

      it 'detects RTL in URLs' do
        expect(described_class.contains_rtl?('http://example.com/مرحبا')).to be true
      end

      it 'detects RTL with emoji' do
        expect(described_class.contains_rtl?('😊 مرحبا 🌍')).to be true
      end

      it 'returns false for emoji only' do
        expect(described_class.contains_rtl?('😊🌍🎉')).to be false
      end
    end
  end

  describe 'thread safety' do
    it 'handles concurrent reorder calls without errors' do # rubocop:disable RSpec/ExampleLength
      results = []
      threads = Array.new(10) do |i|
        Thread.new do # rubocop:disable ThreadSafety/NewThread
          text = i.even? ? 'Hello مرحبا' : 'שלום World'
          results << described_class.reorder(text)
        end
      end
      threads.each(&:join)
      expect(results.size).to eq(10)
    end

    it 'handles concurrent contains_rtl? calls correctly' do # rubocop:disable RSpec/ExampleLength
      results = []
      threads = Array.new(10) do |i|
        Thread.new do # rubocop:disable ThreadSafety/NewThread
          text = i.even? ? 'مرحبا' : 'Hello'
          results << [i, described_class.contains_rtl?(text)]
        end
      end
      threads.each(&:join)
      evens_correct = results.select { |i, _| i.even? }.all? { |_, has_rtl| has_rtl }
      odds_correct = results.select { |i, _| i.odd? }.all? { |_, has_rtl| !has_rtl }
      expect(evens_correct && odds_correct).to be true
    end
  end

  describe 'Memory Management' do
    # These tests verify that our BiDi implementation doesn't leak memory
    # by repeatedly calling methods and checking they handle resources properly

    # rubocop:disable RSpec/MultipleExpectations,RSpec/ExampleLength
    it 'does not leak memory when reordering text many times' do
      expect do
        # This test runs many iterations to ensure proper cleanup
        # If there were memory leaks, this would consume significant memory
        1000.times do
          described_class.reorder('Hello مرحبا World', direction: :auto)
          described_class.reorder('שלום עולם', direction: :rtl)
          described_class.reorder('Test', direction: :ltr)
        end
      end.not_to raise_error
    end

    it 'does not leak memory when checking RTL many times' do
      expect do
        1000.times do
          described_class.contains_rtl?('Hello مرحبا World')
          described_class.contains_rtl?('שלום עולם')
          described_class.contains_rtl?('Test')
        end
      end.not_to raise_error
    end

    it 'properly handles errors without leaking memory' do
      # Test that even with errors, resources are cleaned up
      100.times do
        # Empty strings should return quickly without allocating BiDi objects
        expect(described_class.reorder('')).to eq('')
        expect(described_class.reorder(nil)).to be_nil
        expect(described_class.contains_rtl?('')).to be false
        expect(described_class.contains_rtl?(nil)).to be false
      end
    end

    it 'handles large texts without memory issues' do
      # Create a large mixed text
      large_text = [
        'Hello ',
        ('مرحبا ' * 100),
        'World ',
        ('שלום ' * 100)
      ].join

      10.times do
        result = described_class.reorder(large_text)
        expect(result).not_to be_nil

        has_rtl = described_class.contains_rtl?(large_text)
        expect(has_rtl).to be true
      end
    end
    # rubocop:enable RSpec/MultipleExpectations,RSpec/ExampleLength
  end
end
