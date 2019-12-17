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

    private

    def assert_result(input, output)
      assert_equal(output, Computer.new(input).execute)
    end
  end
end