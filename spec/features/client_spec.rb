require 'helpers/spec_helper'

RSpec.describe OlapXmla::Client do
  before :each do
    @test_mdx = "SELECT {} ON COLUMNS, {} ON ROWS FROM [#{ENV['TEST_CUBE']}]"
    setup_default_client_propeties
  end

  def create_client
    OlapXmla.add_client(:test) do |client_config|
      client_config.name = "Test"
      client_config.options = @test_options
      client_config.server = @test_server
      client_config.data_source = @test_data_source
      client_config.catalog = @test_catalog
    end
    @test_client = OlapXmla.clients[:test]
  end

  def setup_default_client_propeties
    @test_catalog = ENV["TEST_CATALOG"]
    @test_data_source = ENV["TEST_DATA_SOURCE"]
    @test_options = {
      basic_auth: [ENV["TEST_USERNAME"], ENV["TEST_PASSWORD"]]
    }
    @test_server = ENV["TEST_SERVER"]
  end

  def execute_mdx
    @mdx_response = @test_client.execute_mdx @test_mdx
  end

  context '#execute_mdx method' do
    it 'should execute mdx with correct parameters' do
      create_client
      execute_mdx
      expect(@mdx_response.class).to eq(OlapXmla::Response)
    end

    context 'should raise error' do
      it 'when client has wrong initialization parameters' do
        @test_catalog = "ERROR"
        create_client

        expect{execute_mdx}.to raise_error(OlapXmla::ExecutionError)
      end

      it 'when mdx is incorrect' do
        create_client
        @test_mdx += "ERROR"

        expect{execute_mdx}.to raise_error(OlapXmla::ExecutionError)
      end
    end
  end
end

