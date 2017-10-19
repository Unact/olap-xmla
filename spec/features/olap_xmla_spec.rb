require 'support/spec_helper'

RSpec.describe OlapXmla do
  context '#find_client_by_cube method' do

    it 'should find with correct name' do
      (0..2).collect do |number|
        OlapXmla.add_client('test_#{number}'.to_sym) do |config|
          config.server = 'test_server_#{number}'
          config.data_source = 'test_data_source_#{number}'
          config.catalog = 'test_catalog_#{number}'
          config.name = 'test_client_{numbar}'
        end.cube_name
      end.each do |cube_name|
        expect(OlapXmla.find_client_by_cube(cube_name).cube_name).to eq(cube_name)
      end
    end

    it 'should not find with incorrect name' do
      expect(OlapXmla.find_client_by_cube('error')).to eq(nil)
    end
  end

  context '#add_client method' do
    def create_client
      OlapXmla.add_client(:test) do |config|
        config.server = 'test_server'
        config.data_source = 'test_data_source'
        config.catalog = 'test_catalog'
        config.name = 'test_client'
      end
    end

    it 'should raise error if server/data_source/catalog/name are not set' do
      expect{OlapXmla.add_client(:test) {|config|}}.to raise_error(RuntimeError)
      expect(create_client).to_not eq(nil)
    end

    it 'should return created client' do
      new_client = create_client

      expect(OlapXmla.clients[:test]).to eq(new_client)
    end
  end
end
