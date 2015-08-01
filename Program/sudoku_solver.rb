#Please update this according to your system
MINISAT_PATH = "/usr/local/bin/minisat_release"

class SudokuSolver
  #Return the number of the variable of cell i, j and digit d
  #should be an integer within range 1 - 729
  def variable(i, j, d)
    return (i-1)*81 + (j-1)*9 + d
  end

  def valid(cells)
    res = []
    cells.each_with_index do |xi, i|
      cells.each_with_index do |xj, j|
        if (i < j)
          (1..9).each do |d|
            res << [-variable(xi[0], xi[1], d), -variable(xj[0], xj[1], d)]
          end
        end
      end
    end

    res
  end

  #create all clauses for sudoku problem
  def sudoku_clauses
    res = []

    #ensure each cell contains a digit
    (1..9).each do |i|
      (1..9).each do |j|
        #must contains at least one of 9 digits
        res << (1..9).map {|d| variable(i, j, d) }

        (1..9).each do |d|
          ((d+1)..9).each do |dp|
            #can not contain two digits at once
            res << [-variable(i, j, d), -variable(i, j, dp)]
          end
        end
      end
    end

    #ensure each rows and columns contain distinct values
    (1..9).each do |i|
      res += valid( (1..9).map{|j| [i, j]} )
      res += valid( (1..9).map{|j| [j, i]} )
    end

    #ensure 3x3 sub-grids regions have distinct values
    [1, 4, 7].each do |i|
      [1, 4, 7].each do |j|
        res += valid((0..8).map{|k| [i + k%3, j+k / 3]})
      end
    end

    res
  end

  def run_minisat_on_file(file)
    output_file = "sudoku_minisat_output.txt"
    minisat_found = `which #{MINISAT_PATH}`

    if minisat_found
      `#{MINISAT_PATH} #{file} #{output_file}`
    else
      puts "Can not find miniSAT at #{MINISAT_PATH}, please update MINISAT_PATH constant in sudoku_solver.rb"
      exit
    end

    f = File.open(output_file, "r")
    sat = f.readline.strip
    solutions = f.readline.split(/\s+/).map(&:to_i)

    if sat == "SAT"
      puts "SUDOKU is solved!"
    else
      puts "Can not solve this SUDOKU"
    end

    solutions
  end

  def solve(grid)
    clauses = sudoku_clauses

    (1..9).each do |i|
      (1..9).each do |j|
        d = grid[i-1][j-1]
        print "#{d} "
        if d > 0
          clauses << [variable(i, j, d)]
        end
      end
      puts ""
    end

    puts ""
    puts "Solving...\n\n"

    generated_file = "sudoku_cnf.txt"

    #write all clauses to DIMACS file as input to miniSAT
    File.open(generated_file, "w") do |f|
      f.puts "c This file is auto-generated. This CNF is for solving the following sudoku problem"

      (1..9).each do |i|
        f.puts "c #{(1..9).map{|j| grid[i-1][j-1] }.join(' ')}"
      end

      f.puts "p cnf 729 #{clauses.count}"
      clauses.each do |clause|
        f.puts "#{clause.join(' ')} 0"
      end
    end

    #call miniSAT to solve the problem
    solutions = run_minisat_on_file(generated_file)

    (1..9).each do |i|
      (1..9).each do |j|
        (1..9).each do |d|
          if solutions.include?(variable(i, j, d))
            grid[i-1][j-1] = d
            print "#{d} "
          end
        end
      end

      puts ""
    end

    grid
  end
end