require_relative 'optcode'

file = File.open('./input2.txt')
string_input = file.read
array_of_numbers = string_input.split(",").map(&:to_i)

(0..99).each do |i|
  array_of_numbers[1] = i
  (0..99).each do |j|
    array_of_numbers[2] = j
    result = Optcode::Computer.new(array_of_numbers.clone).execute[0]
    if result == 19690720
      puts 100 * i + j
    end
  end
end
