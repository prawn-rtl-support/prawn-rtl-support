# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Prawn::Rtl::Connector do
  let(:initial_codepoints) { [1580, 1576, 1587, 32, 1586, 1585, 1575, 1593, 1609, 32, 45, 32, 1587, 1575, 1574, 1576] }
  let(:initial_string) { initial_codepoints.pack('U*') }
  let(:final_codepoints) do
    [65_168, 65_163, 65_166, 65_203, 32, 45, 32, 65_264, 65_227, 65_165, 65_197, 65_199, 32, 65_202, 65_170, 65_183]
  end
  let(:final_string) { final_codepoints.pack('U*') }

  it 'connect arabic string and reverse' do
    expect(described_class.fix_rtl(initial_string)).to eq(final_string)
  end
end
