module OlapXmla
  class Response

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
      axis_info "Axis0"
    end

    # Collection of dimensions in response
    #  {
    #    :name,  the name of dimension
    #    :caption display name of dimension
    #  }
    def dimensions
      axis_info "Axis1"
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
            value = non_empty_cell[:fmt_value]
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

    # Maps columns for mdx matrix
    #  [{
    #     :column_<column_number> => column_value
    #  }]
    def map_columns
      matrix.collect do |row|
        result = {}
        row.each.with_index{|value, index| result["column_#{index}".to_sym] = value }
        result
      end
    end

    private
      def axis_info axis_name
        axis = response[:axes][:axis].find{ |el| el[:@name] == axis_name }

        return [] if axis[:tuples].nil?

        [axis[:tuples][:tuple]].flatten.collect do |tuple|
          axis_values = tuple[:member]
          {
            name: axis_values_prop(axis_values, :u_name),
            caption: axis_values_prop(axis_values, :caption)
          }
        end
      end

      def axis_values_prop axis_values, prop
        axis_values.is_a?(Array) ? axis_values.collect{|value| value[prop]}.join('; ') : axis_values[prop]
      end
  end
end
