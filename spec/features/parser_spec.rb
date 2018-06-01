require 'support/spec_helper'

RSpec.describe OlapXmla::Parser do
  describe '#parse_value' do
    context 'should parse' do
      it 'integer types correctly' do
        expect(OlapXmla::Parser.parse_value('1', 'xsd:short')).to eq(1)
        expect(OlapXmla::Parser.parse_value('-1', 'xsd:int')).to eq(-1)
        expect(OlapXmla::Parser.parse_value('11111111111111111111', 'xsd:long')).to eq(11111111111111111111)
        expect(OlapXmla::Parser.parse_value('1', 'xsd:unsignedShort')).to eq(1)
        expect(OlapXmla::Parser.parse_value('-1', 'xsd:unsignedInt')).to eq(-1)
        expect(OlapXmla::Parser.parse_value('11111111111111111111', 'xsd:unsignedLong')).to eq(11111111111111111111)
      end

      it 'float types correctly' do
        expect(OlapXmla::Parser.parse_value('-1.0', 'xsd:decimal')).to eq(-1.0)
        expect(OlapXmla::Parser.parse_value('1.2', 'xsd:double')).to eq(1.2)
        expect(OlapXmla::Parser.parse_value('1.E', 'xsd:float')).to eq(1.0)
        expect(OlapXmla::Parser.parse_value('2.E2', 'xsd:float')).to eq(200.0)
        expect(OlapXmla::Parser.parse_value('2.0E2', 'xsd:float')).to eq(200.0)
        expect(OlapXmla::Parser.parse_value('NaN', 'xsd:float').nan?).to eq(true)
      end

      it 'date correctly' do
        test_date = Date.new(2017, 1, 1)
        expect(OlapXmla::Parser.parse_value(test_date.to_s, 'xsd:date')).to eq(test_date)
      end

      it 'time correctly' do
        test_time = Time.new(2017, 1, 1, 0, 0)
        expect(OlapXmla::Parser.parse_value(test_time.to_s, 'xsd:time')).to eq(test_time)
      end
    end

    context 'should not change data' do
      it 'for binary types' do
        expect(OlapXmla::Parser.parse_value('200', 'xsd:byte')).to eq('200')
        expect(OlapXmla::Parser.parse_value('01101101', 'xsd:binary')).to eq('01101101')
        expect(OlapXmla::Parser.parse_value('200', 'xsd:unsignedByte')).to eq('200')
        expect(OlapXmla::Parser.parse_value('test', 'xsd:string')).to eq('test')
      end

      it 'for unknown types' do
        expect(OlapXmla::Parser.parse_value('test', 'xsd:test')).to eq('test')
      end
    end
  end
end
