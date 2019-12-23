require_relative 'optcode'

array_of_numbers = File.open('./input5.txt').read.split(",").map(&:to_i)

Optcode::Computer.new(STDIN, STDOUT, array_of_numbers).execute
