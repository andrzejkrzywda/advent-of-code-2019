require 'minitest/autorun'
require './optcode'

module Optcode
  class OptcodeTest < Minitest::Test

    def test_longer_programs
      assert_result(
        [1,9,10,3,2,3,11,0,99,30,40,50],
        [3500,9,10,70,2,3,11,0,99,30,40,50])
      assert_result([1,0,0,0,99], [2,0,0,0,99])
      assert_result([2,3,0,3,99], [2,3,0,6,99])
      assert_result([2,4,4,5,99,0], [2,4,4,5,99,9801])
      assert_result([1,1,1,4,99,5,6,0,99], [30,1,1,4,2,5,6,0,99])
    end

    def test_5_1_acceptance
      fake_stdout = FakeStdout.new
      Optcode::Computer.new(fake_stdin([1]), fake_stdout, input_5_file_data).execute
      assert_equal(8332629, fake_stdout.contents.last)
    end

    def test_5_2_acceptance
      fake_stdout = FakeStdout.new
      Optcode::Computer.new(fake_stdin([5]), fake_stdout, input_5_file_data).execute
      assert_equal([8805067], fake_stdout.contents)
    end

    def test_7_1_acceptance
      possible_phases = [0,1,2,3,4]
      final_outputs = []
      possible_phases.permutation.each do |phases|
        output = run_thruster(phases[0], 0)
        output = run_thruster(phases[1], output)
        output = run_thruster(phases[2], output)
        output = run_thruster(phases[3], output)
        output = run_thruster(phases[4], output)
        final_outputs << output
      end
      assert_equal(338603, final_outputs.max)
    end

    def run_thruster(phase, input)
      fake_stdout = FakeStdout.new
      Optcode::Computer.new(fake_stdin([phase, input]), fake_stdout, input_7_file_data).execute
      return fake_stdout.contents.first
    end

    def test_unknown_instruction
      assert_raises(UnknownInstruction) do
        Computer.new(fake_stdin([55]), FakeStdout.new, [5,0,0,0,99]).execute
      end
    end

    def test_3_input_instruction
      assert_equal(Computer.new(fake_stdin([99]), FakeStdout.new, [3,2,0]).execute, [3, 2, 99])
    end

    private

    def input_5_file_data
      File.open('./input5.txt').read.split(",").map(&:to_i)
    end

    def input_7_file_data
      File.open('./input7.txt').read.split(",").map(&:to_i)
    end

    def assert_result(input, output)
      assert_equal(output, Computer.new(fake_stdin([55]), FakeStdout.new, input).execute)
    end

    def fake_stdin(fake_input)
      FakeStdin.new(fake_input)
    end

    class FakeStdin
      def initialize(inputs)
        @inputs = inputs
      end

      def gets
        @inputs.shift
      end
    end

    class FakeStdout
      attr_accessor :contents
      def initialize
        @contents = []
      end

      def puts(content)
        @contents << content
      end
    end
  end
end