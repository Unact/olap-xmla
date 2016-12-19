module OlapXmla
  class ExecutionError < StandardError
    def initialize response
      @response = response
    end

    def to_s
      "
        Error: #{@response[:error]}
        Cube: #{@response[:client].cube_name}
        MDX: #{@response[:mdx]}"
    end
  end
end
