module Optcode
  class UnknownInstruction < StandardError; end

  class Computer
    def initialize(input, memory)
      @input  = input
      @memory = Memory.new(memory)
    end

    def execute
      @memory.read_instruction do |slice|
        if slice[0] == 1
          add(slice)
        elsif slice[0] == 2
          multiply(slice)
        elsif slice[0] == 3
          store_input(slice)
        elsif slice[0] == 99
          return @memory.content
        else
          raise UnknownInstruction.new(slice[0])
        end
      end
      return @memory.content
    end

    private

    def multiply(slice)
      @memory.content[slice[3]] = @memory.content[slice[1]] * @memory.content[slice[2]]
    end

    def add(slice)
      @memory.content[slice[3]] = @memory.content[slice[1]] + @memory.content[slice[2]]
    end

    def store_input(slice)
      @memory.content[slice[1]] = @input.gets.to_i
    end
  end

  class Memory
    attr_accessor :content

    def initialize(content)
      @content = content
    end

    def read_instruction
      @pointer = 0
      while true do
        if @content[@pointer] == 3
          yield(@content[@pointer..@pointer+1])
          @pointer += 2
        else
          yield(@content[@pointer..@pointer+3])
          @pointer += 4
        end
      end
    end
  end


end