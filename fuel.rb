module Space

  class SpaceModule
    def initialize(mass)
      @mass = mass
    end

    def required_fuel
      fuel_for_modules + fuel_for_modules.required_fuel
    end

    private

    def fuel_for_modules
      Fuel.new((@mass.amount / 3).ceil - 2)
    end
  end

  class Fuel
    attr_accessor :amount
    def initialize(amount)
      @amount = amount
    end

    def ==(other)
      @amount == other.amount
    end

    def required_fuel
      fuel = Fuel.new([0, (@amount / 3).ceil - 2].max)
      return fuel if fuel.amount == 0
      if fuel.amount > 0
        return fuel + fuel.required_fuel
      end
    end

    def +(fuel)
      Fuel.new(@amount + fuel.amount)
    end

  end

  class Mass
    attr_accessor :amount

    def initialize(amount)
      @amount = amount
    end
  end
end