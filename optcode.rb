module Optcode
  class UnknownInstruction < StandardError; end
  class Halted < StandardError;             end

  class Computer
    def initialize(input, memory)
      @input  = input
      @memory = Memory.new(memory)
    end

    def execute
      begin
        execute_all_instructions
      rescue Halted
        return @memory.content
      end
      return @memory.content
    end

    private

    def execute_all_instructions
      InstructionParser.new(@memory).each_instruction(@input) do |instruction|
        instruction.call
      end
    end

  end

  class Add
    def initialize(memory, left, right, output_position)
      @memory = memory
      @left   = left
      @right  = right
      @output_position = output_position
    end

    def call
      @memory.set(@output_position, @left + @right)
    end
  end

  class Multiply
    def initialize(memory, left, right, output_position)
      @memory = memory
      @left   = left
      @right  = right
      @output_position = output_position
    end

    def call
      @memory.set(@output_position, @left * @right)
    end
  end

  class StoreInput
    def initialize(memory, position, input)
      @memory    = memory
      @position  = position
      @input     = input
    end

    def call
      @memory.set(@position, @input.gets.to_i)
    end
  end

  class Memory
    attr_accessor :content

    def initialize(content)
      @content = content
    end

    def set(position, value)
      @content[position] = value
    end

    def get(position)
      @content[position]
    end

    def get_slice(position, length)
      @content[position..position+length+1]
    end

  end

  class InstructionParser
    def initialize(memory)
      @memory  = memory
      @pointer = 0
    end

    def each_instruction(input)
      @pointer = 0
      while true do
        if @memory.get(@pointer) == 1
          yield add
          @pointer += 4
        elsif @memory.get(@pointer) == 2
          yield multiply
          @pointer += 4
        elsif @memory.get(@pointer) == 3
          yield store_input(input)
          @pointer += 2
        elsif @memory.get(@pointer) == 99
          yield -> { raise Halted }
          return
        else
          yield -> {raise UnknownInstruction.new(@memory.get(@pointer))}
        end
      end
    end

    private

    def store_input(input)
      StoreInput.new(@memory, @memory.get(@pointer+1), input)
    end

    def multiply
      slice = @memory.get_slice(@pointer, 4)
      Multiply.new(@memory, @memory.get(slice[1]), @memory.get(slice[2]), slice[3])
    end

    def add
      slice = @memory.get_slice(@pointer, 4)
      Add.new(@memory, @memory.get(slice[1]), @memory.get(slice[2]), slice[3])
    end
  end


end