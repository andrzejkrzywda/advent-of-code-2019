module Optcode
  class UnknownInstruction < StandardError; end
  class Halted < StandardError;             end

  class Computer
    def initialize(input, output, memory)
      @input  = input
      @output = output
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
      InstructionParser.new(@memory).each_instruction(@input, @output) do |instruction|
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

  class JumpIfTrue
    def initialize(parser, param, output_position)
      @parser = parser
      @param  = param
      @output_position = output_position
    end

    def call
      if not @param.zero?
        @parser.move_instruction_pointer_to(@output_position)
      else
        @parser.increase_pointer_by(3)
      end
    end
  end

  class JumpIfFalse
    def initialize(parser, param, output_position)
      @parser = parser
      @param  = param
      @output_position = output_position
    end

    def call
      if @param.zero?
        @parser.move_instruction_pointer_to(@output_position)
      else
        @parser.increase_pointer_by(3)
      end
    end
  end

  class Equals
    def initialize(memory, parser, left, right, output_position)
      @memory = memory
      @parser = parser
      @left   = left
      @right  = right
      @output_position = output_position
    end

    def call
      @memory.set(@output_position, (@left == @right) ? 1 : 0)
      @parser.increase_pointer_by(4)
    end
  end

  class LessThan
    def initialize(memory, parser, left, right, output_position)
      @memory = memory
      @parser = parser
      @left   = left
      @right  = right
      @output_position = output_position
    end

    def call
      @memory.set(@output_position, (@left < @right) ? 1 : 0)
      @parser.increase_pointer_by(4)
    end
  end

  class StoreInput
    def initialize(memory, position, input)
      @memory    = memory
      @position  = position
      @input     = input
    end

    def call
      input = @input.gets.to_i
      @memory.set(@position, input)
    end
  end

  class OutputValue
    def initialize(value, output)
      @value  = value
      @output = output
    end

    def call
      @output.puts(@value)
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

    def each_instruction(input, output)
      @pointer = 0
      while true do
        if instruction_ends_with?(1)
          yield add
          @pointer += 4
        elsif instruction_ends_with?(2)
          yield multiply
          @pointer += 4
        elsif instruction_ends_with?(3)
          yield store_input(input)
          @pointer += 2
        elsif instruction_ends_with?(4)
          yield output_value(output)
          @pointer += 2
        elsif instruction_ends_with?(5)
          yield jump_if_true
        elsif instruction_ends_with?(6)
          yield jump_if_false
        elsif instruction_ends_with?(7)
          yield less_than
        elsif instruction_ends_with?(8)
          yield equals
        elsif instruction_ends_with?(99)
          yield -> { raise Halted }
        else
          yield -> {raise UnknownInstruction.new(@memory.get(@pointer))}
        end
      end
    end

    def move_instruction_pointer_to(new_pointer)
      @pointer = new_pointer
    end

    def increase_pointer_by(count)
      @pointer += count
    end

    private

    def halt_instruction?
      @memory.get(@pointer) == 99
    end

    def instruction_ends_with?(number)
      @memory.get(@pointer) == number ||
        @memory.get(@pointer).to_s.end_with?(number.to_s)
    end

    def store_input(input)
      StoreInput.new(@memory, @memory.get(@pointer+1), input)
    end

    def jump_if_true
      param, output_position  = get_param_and_output_position
      JumpIfTrue.new(self, param, output_position)
    end

    def jump_if_false
      param, output_position  = get_param_and_output_position
      JumpIfFalse.new(self, param, output_position)
    end

    def get_param_and_output_position
      instruction = Instruction.new(@memory.get(@pointer).to_s)
      if instruction.param_1_mode == "0"
        param = @memory.get(@memory.get(@pointer + 1))
      else
        param = @memory.get(@pointer + 1)
      end
      if instruction.param_2_mode == "0"
        output_position = @memory.get(@memory.get(@pointer + 2))
      else
        output_position = @memory.get(@pointer + 2)
      end
      return param, output_position
    end

    def equals
      left, right, output_position = retrieve_values
      Equals.new(@memory, self, left, right, output_position)
    end

    def less_than
      left, right, output_position = retrieve_values
      LessThan.new(@memory, self, left, right, output_position)
    end

    def output_value(output)
      instruction = Instruction.new(@memory.get(@pointer).to_s)
      if instruction.param_1_mode == "0"
        value = @memory.get(@memory.get(@pointer+1))
      else
        value = @memory.get(@pointer+1)
      end
      OutputValue.new(value, output)
    end

    def multiply
      left, right, output_position = retrieve_values
      Multiply.new(@memory, left, right, output_position)
    end

    def retrieve_values
      slice = @memory.get_slice(@pointer, 4)
      instruction = Instruction.new(slice[0].to_s)
      if instruction.param_1_mode == "0"
        left = @memory.get(slice[1])
      else
        left = slice[1]
      end
      if instruction.param_2_mode == "0"
        right = @memory.get(slice[2])
      else
        right = slice[2]
      end
      return left, right, slice[3]
    end

    def add
      left, right, output_position = retrieve_values
      Add.new(@memory, left, right, output_position)
    end
  end

  class Instruction
    def initialize(code)
      @code = code.rjust(5, '0')
    end

    def opcode
      @code[-2..-1].merge.to_i
    end

    def param_1_mode
      @code[2]
    end

    def param_2_mode
      @code[1]
    end

    def param_3_mode
      @code[0]
    end
  end
end