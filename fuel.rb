module Space

  class SpaceModule
    def initialize(mass)
      @mass = mass
    end

    def required_fuel
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

  end

  class Mass
    attr_accessor :amount

    def initialize(amount)
      @amount = amount
    end
  end
end