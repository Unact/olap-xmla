require "date"
require "time"

module OlapXmla
  module Parser
    # XML type to ruby type mapping taken from
    # https://msdn.microsoft.com/en-us/library/ms977626.aspx#xmlanalysis_topic14
    def self.parse_value val, type
      case type.sub('xsd:', '')
      when 'short', 'int', 'long', 'unsignedShort', 'unsignedInt', 'unsignedLong'
        val.to_i
      when 'decimal', 'double', 'float'
        val != 'NaN' ? val.gsub('.E', '.0E').to_f : Float::NAN
      when 'date'
        Date.parse(val)
      when 'time'
        Time.parse(val)
      when 'byte', 'binary', 'unsignedByte', 'string'
        val
      else
        val
      end
    end
  end
end
