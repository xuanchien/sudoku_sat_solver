require_relative 'sudoku_solver'

if ARGV.length == 0
  puts "Please specify input file"
  exit
end

input_file = ARGV.first

#read problem from the input file
grid = []
text = File.open(input_file, "r").read
text.gsub!(/\r\n?/, "\n")

text.each_line do |line|
  grid << line.split(/\s+/).map(&:to_i)
end

sudoku_solver = SudokuSolver.new

grid = sudoku_solver.solve(grid)

#Write the solution to output file
output_file = File.basename(input_file, ".txt") + "_result.txt"
File.open(output_file, "w") do |f|
  (1..9).each do |i|
    (1..9).each do |j|
      f.print "#{grid[i-1][j-1]} "
    end
    f.puts ""
  end
end

puts "DONE"