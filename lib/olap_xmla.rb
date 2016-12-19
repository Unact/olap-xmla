require "olap_xmla/version"
require "olap_xmla/client"
require "olap_xmla/response"
require "olap_xmla/execution_error"

module OlapXmla
  @@clients = {}

  # Used to add new clients
  def self.add_client client_name
    client_configuration = OlapXmla::ClientConfiguration.new
    yield client_configuration

    unless
      client_configuration.name &&
      client_configuration.server &&
      client_configuration.data_source &&
      client_configuration.catalog
    then
      raise "OlapXmla initialization error not all configuration params are set!"
    end

    self.clients[client_name] = OlapXmla::Client.new(
      client_configuration.name,
      client_configuration.server,
      client_configuration.data_source,
      client_configuration.catalog,
      client_configuration.options
    )

    self.clients[client_name]
  end

  # Hash of all avaliable clients
  def self.clients
    @@clients
  end

  # Used for finding a client by its cube name
  def self.find_client_by_cube cube_name
    self.clients.select{|key, value| value.cube_name == cube_name}.values[0]
  end
end
