require_relative 'optcode'

file = File.open('./input2.txt')
string_input = file.read
array_of_numbers = string_input.split(",").map(&:to_i)
puts array_of_numbers.inspect

array_of_numbers[1] = 12
array_of_numbers[2] = 2

puts Optcode::Computer.new(array_of_numbers).execute[0]
# 4714701