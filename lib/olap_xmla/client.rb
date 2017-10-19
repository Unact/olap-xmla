require "savon"

module OlapXmla
  class Client
    attr_reader :data_source, :catalog, :savon_client, :options, :name, :server

    def initialize name, server, data_source, catalog, options
      options ||= {}
      @name = name
      @server = server
      @catalog = catalog
      @data_source = data_source
      @options = default_options.merge(options)
      @savon_client = Savon.client(@options)
    end

    def execute_mdx mdx
      operation = @savon_client.operation("Execute")
      result = operation.call(message: wsdl_message(mdx))

      unless result.success?
        error_data = {
          client: self,
          error: "#{result.http_error} #{result.soap_fault}",
          mdx: mdx
        }
        raise OlapXmla::ExecutionError, error_data
      end
      
      OlapXmla::Response.new result, mdx
    end

    def cube_name
      "#{@data_source}\\#{@catalog}"
    end

    private
      def wsdl_message mdx
        {
          "wsdl:Command" =>  {
            "wsdl:Statement" => mdx
          },
          "wsdl:Properties" => wsdl_properties
        }
      end

      def wsdl_properties
        {
          "wsdl:PropertyList" => {
            "wsdl:DataSourceInfo" => @data_source,
            "wsdl:Catalog" => @catalog,
            "wsdl:Format" => "Multidimensional",
            "wsdl:AxisFormat"=> "TupleFormat"
          }
        }
      end

      # Can be changed by passing options
      def default_options
        {
          open_timeout: 300,
          read_timeout: 300,
          raise_errors: false,
          endpoint: @server,
          namespace: "urn:schemas-microsoft-com:xml-analysis"
        }
      end
  end

  class ClientConfiguration
    attr_accessor :name, :server, :data_source, :catalog, :options
  end
end
