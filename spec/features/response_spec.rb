require 'helpers/spec_helper'

RSpec.describe OlapXmla::Response do
  before :each do
    OlapXmla.add_client(:test) do |client_config|
      client_config.name = "Test"
      client_config.options = {
        basic_auth: [ENV["TEST_USERNAME"], ENV["TEST_PASSWORD"]]
      }
      client_config.server = ENV["TEST_SERVER"]
      client_config.data_source = ENV["TEST_DATA_SOURCE"]
      client_config.catalog = ENV["TEST_CATALOG"]
    end

    @test_client = OlapXmla.clients[:test]
    @test_measures = ['[Measures].[Бонус за DEV]']
    @test_dimensions = ['[Дата].[Календарь].DEFAULTMEMBER']
    test_mdx = "
      SELECT
        { #{@test_measures.join(',')}  } ON COLUMNS ,
        { #{@test_dimensions.join(',')} } ON ROWS
      FROM [#{ENV['TEST_CUBE']}]"
    @mdx_response = @test_client.execute_mdx test_mdx
  end


  it 'should have data' do
    expect(@mdx_response.has_data?).to eq(true)
  end

  it 'should return measures' do
    expect(@mdx_response.measures.length).to eq(@test_measures.length)
  end

  it 'should return dimensions' do
    expect(@mdx_response.dimensions.length).to eq(@test_dimensions.length)
  end

  it 'should return cell values' do
    expect(@mdx_response.row_values.length).to eq(@test_dimensions.length)
    @mdx_response.row_values.each do |row|
      expect(row.length).to eq(@test_measures.length)
    end
  end

  it 'should return matrix' do
    @mdx_response.matrix.each.with_index do |row, row_index|
      row.each.with_index do |column, column_index|
        if row_index == 0
          if column_index == 0
            expect(column).to eq(nil)
          else
            expect(column).to eq(@mdx_response.measures[column_index-1][:caption])
          end
        elsif column_index == 0
          expect(column).to eq(@mdx_response.dimensions[row_index-1][:caption])
        end
      end
    end
  end

  it 'should return mapped rows' do
    column_names_hash = (0..@mdx_response.matrix[0].length-1).collect do |column_number|
      "column_#{column_number}".to_sym
    end

    @mdx_response.map_columns.each.with_index do |row, index|
      expect(row.keys).to eq(column_names_hash)
    end
  end
end
