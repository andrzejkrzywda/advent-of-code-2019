require './fuel'

lines = File.open('./input.txt')
result = 0
lines.each do |line|
  result += Space::SpaceModule.new(Space::Mass.new(line.to_i)).required_fuel.amount
end
puts result