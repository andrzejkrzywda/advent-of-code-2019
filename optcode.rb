module Optcode
  class UnknownInstruction < StandardError; end

  class Computer
    def initialize(input, memory)
      @input  = input
      @memory = memory
    end

    def execute
      read_slice do |slice|
        if slice[0] == 1
          add(slice)
        elsif slice[0] == 2
          multiply(slice)
        elsif slice[0] == 3
          store_input(slice)
        elsif slice[0] == 99
          return @memory
        else
          raise UnknownInstruction.new(slice[0])
        end
      end
      return @memory
    end

    private

    def read_slice
      @pointer = 0
      while true do
        if @memory[@pointer] == 3
          yield(@memory[@pointer..@pointer+1])
          @pointer += 2
        else
          yield(@memory[@pointer..@pointer+3])
          @pointer += 4
        end
      end

    end

    def multiply(slice)
      @memory[slice[3]] = @memory[slice[1]] * @memory[slice[2]]
    end

    def add(slice)
      @memory[slice[3]] = @memory[slice[1]] + @memory[slice[2]]
    end

    def store_input(slice)
      @memory[slice[1]] = @input.gets.to_i
    end
  end
end