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
    def initialize(memory, slice)
      @memory = memory
      @slice  = slice
    end

    def call
      @memory.set(@slice[3], @memory.get(@slice[1]) + @memory.get(@slice[2]))
    end
  end

  class Multiply
    def initialize(memory, slice)
      @memory = memory
      @slice  = slice
    end

    def call
      @memory.set(@slice[3], @memory.content[@slice[1]] * @memory.content[@slice[2]])
    end
  end

  class StoreInput
    def initialize(memory, slice, input)
      @memory = memory
      @slice  = slice
      @input  = input
    end

    def call
      @memory.set(@slice[1], @input.gets.to_i)
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
          yield Add.new(@memory, @memory.get_slice(@pointer, 4))
          @pointer += 4
        elsif @memory.get(@pointer) == 2
          yield Multiply.new(@memory, @memory.get_slice(@pointer, 4))
          @pointer += 4
        elsif @memory.get(@pointer) == 3
          yield StoreInput.new(@memory, @memory.get_slice(@pointer, 2), input)
          @pointer += 2
        elsif @memory.get(@pointer) == 99
          yield -> { raise Halted }
          return
        else
          yield -> {raise UnknownInstruction.new(@memory.get(@pointer))}
        end
      end
    end
  end


end