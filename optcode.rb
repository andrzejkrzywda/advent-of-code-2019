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
        @memory.each_instruction do |slice|
          if slice[0] == 1
            Add.new.call(@memory, slice)
          elsif slice[0] == 2
            Multiply.new.call(@memory, slice)
          elsif slice[0] == 3
            StoreInput.new.call(@memory, slice, @input)
          elsif slice[0] == 99
            Halt.new(@memory, slice, @input).call
          else
            raise UnknownInstruction.new(slice[0])
          end
        end
      rescue Halted
        return @memory.content
      end
      return @memory.content
    end

  end

  class Add
    def call(memory, slice)
      memory.content[slice[3]] = memory.content[slice[1]] + memory.content[slice[2]]
    end
  end

  class Multiply
    def call(memory, slice)
      memory.content[slice[3]] = memory.content[slice[1]] * memory.content[slice[2]]
    end
  end

  class StoreInput
    def call(memory, slice, input)
      memory.content[slice[1]] = input.gets.to_i
    end
  end

  class Halt
    def initialize(memory, slice, input)
    end

    def call
      raise Halted
    end
  end

  class Memory
    attr_accessor :content

    def initialize(content)
      @content = content
    end

    def each_instruction
      @pointer = 0
      while true do
        if @content[@pointer] == 1
          yield(@content[@pointer..@pointer+3])
          @pointer += 4
        elsif @content[@pointer] == 2
          yield(@content[@pointer..@pointer+3])
          @pointer += 4
        elsif @content[@pointer] == 3
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