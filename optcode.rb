module Optcode
  class UnknownInstruction < StandardError; end

  class Computer
    def initialize(input)
      @input = input
    end

    def execute
      @input.each_slice(4) do |slice|
        if slice[0] == 1
          add(slice)
        elsif slice[0] == 2
          multiply(slice)
        elsif slice[0] == 99
          return @input
        else
          raise UnknownInstruction.new("unknown instruction: #{slice[0]}")
        end
      end
      return @input
    end

    private

    def multiply(slice)
      @input[slice[3]] = @input[slice[1]] * @input[slice[2]]
    end

    def add(slice)
      @input[slice[3]] = @input[slice[1]] + @input[slice[2]]
    end
  end
end