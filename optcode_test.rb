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

    def test_unknown_instruction
      assert_raises(UnknownInstruction) do
        Computer.new(fake_stdin(55), fake_stdout, [5,0,0,0,99]).execute
      end
    end

    def test_3_input_instruction
      assert_equal(Computer.new(fake_stdin(99), fake_stdout, [3,2,0]).execute, [3, 2, 99])
    end

    private

    def assert_result(input, output)
      assert_equal(output, Computer.new(fake_stdin(55), fake_stdout, input).execute)
    end

    def fake_stdin(fake_input)
      fake_stdin = Object.new
      fake_stdin.define_singleton_method(:gets) do
        "#{fake_input}\n"
      end
      fake_stdin
    end

    def fake_stdout
      fake_stdout = Object.new
      fake_stdout.define_singleton_method(:puts) do |content|
        fake_stdout.instance_variable_set(:content, content)
      end
      fake_stdout.define_singleton_method(:content) do
        fake_stdout.instance_variable_get(:content)
      end
      fake_stdout
    end
  end
end