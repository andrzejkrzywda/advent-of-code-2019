require 'minitest/autorun'
require './fuel'

module Space

  class FuelTest < Minitest::Test

    def test_single_modules
      assert_required_fuel_for_module(2, 12)
      assert_required_fuel_for_module(2, 14)
      assert_required_fuel_for_module(654, 1969)
      assert_required_fuel_for_module(33583, 100756)
    end

    private

    def assert_required_fuel_for_module(fuel, mass)
      assert_equal(Fuel.new(fuel), fuel_for_module(mass))
    end

    def fuel_for_module(mass)
      SpaceModule.new(Mass.new(mass)).required_fuel
    end
  end
end