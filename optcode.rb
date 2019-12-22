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
        @memory.each_instruction(@input) do |instruction|
          instruction.call
        end
      rescue Halted
        return @memory.content
      end
      return @memory.content
    end

  end

  class Add
    def initialize(memory, slice)
      @memory = memory
      @slice  = slice
    end

    def call
      @memory.content[@slice[3]] = @memory.content[@slice[1]] + @memory.content[@slice[2]]
    end
  end

  class Multiply
    def initialize(memory, slice)
      @memory = memory
      @slice  = slice
    end

    def call
      @memory.content[@slice[3]] = @memory.content[@slice[1]] * @memory.content[@slice[2]]
    end
  end

  class StoreInput
    def initialize(memory, slice, input)
      @memory = memory
      @slice  = slice
      @input  = input
    end

    def call
      @memory.content[@slice[1]] = @input.gets.to_i
    end
  end

  class Memory
    attr_accessor :content

    def initialize(content)
      @content = content
    end

    def each_instruction(input)
      @pointer = 0
      while true do
        if @content[@pointer] == 1
          yield Add.new(self, @content[@pointer..@pointer+3])
          @pointer += 4
        elsif @content[@pointer] == 2
          yield Multiply.new(self, @content[@pointer..@pointer+3])
          @pointer += 4
        elsif @content[@pointer] == 3
          yield StoreInput.new(self, @content[@pointer..@pointer+1], input)
          @pointer += 2
        elsif @content[@pointer] == 99
          yield -> { raise Halted }
          return
        else
          yield -> {raise UnknownInstruction.new(@content[@pointer])}
        end
      end
    end
  end


end