module OlapXmla
  class Response
    include OlapXmla::Parser

    attr_reader :mdx, :response

    def initialize response, mdx
      @response = response
      @mdx = mdx
    end

    # Returns true if the response has any data
    def has_data?
      !response[:cell_data].nil?
    end

    # Collection of measures in response
    #  {
    #    :name,  the name of measure
    #    :caption display name of measure
    #  }
    def measures
      axis "Axis0"
    end

    # Collection of dimensions in response
    #  {
    #    :name,  the name of dimension
    #    :caption display name of dimension
    #  }
    def dimensions
      axis "Axis1"
    end

    # Collection of rows with formatted values
    def row_values
      column_count = measures.length
      row_count = dimensions.length
      cells = has_data? ? [response[:cell_data][:cell]].flatten : []
      cell_index = 0
      (0..row_count-1).collect do |row|
        (0..column_count-1).collect do |column|
          value = nil

          if non_empty_cell = cells.find{|cell| cell[:@cell_ordinal].to_i == cell_index }
            value = Parser.parse_value non_empty_cell[:value], non_empty_cell[:value].attributes['xsi:type']
          end
          cell_index+=1

          value
        end
      end
    end

    # Mdx values matrix with measures in the first row and dimensions in the first column
    def matrix
      rows_with_column_names = row_values.unshift(measures.collect{|measure| measure[:caption]})
      (1..dimensions.length).collect do |dimension_index|
        rows_with_column_names[dimension_index].unshift(dimensions[dimension_index-1][:caption])
      end.unshift(rows_with_column_names[0].unshift(nil))
    end

    private
      def axis axis_name
        axis = response[:axes][:axis].find{ |el| el[:@name] == axis_name }
        axis_info = response[:olap_info][:axes_info][:axis_info].find {|el| el[:@name] == axis_name}
        return [] if axis[:tuples].nil?
        [axis[:tuples][:tuple]].flatten.collect do |tuple|
          axis_value = tuple[:member]

          {
            name: Parser.parse_value(axis_value[:u_name], axis_info[:hierarchy_info][:u_name][:@type]),
            caption: Parser.parse_value(axis_value[:caption], axis_info[:hierarchy_info][:caption][:@type])
          }
        end
      end
  end
end
