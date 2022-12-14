module Advent2022
  class Forest

    def initialize
      @grid = []
    end

    def self.from_file(name)
      f  = Forest.new

      File.readlines(name).each do |line|
        f.add_trees_line(line)
      end

      f
    end

    def add_trees_line(line)
      @grid << line.strip.chars.map { |ch| ch.to_i }
    end  

    def visible?(i, j)
      height = @grid[i][j]

      left(i, j).max < height || right(i, j).max < height ||
      top(i, j).max < height || down(i, j).max < height
    end

    def visible
      v = 0
      (0..(@grid.size-1)).each do |i|
        (0..(@grid[i].size-1)).each do |j|
          v += 1 if visible?(i, j)
        end
      end

      v
    end

    def scenic_score(i, j)
      viewing_distance(@grid[i][j], top(i, j)) *
      viewing_distance(@grid[i][j], left(i, j)) *
      viewing_distance(@grid[i][j], down(i, j)) *
      viewing_distance(@grid[i][j], right(i, j))
    end

    def max_scenic_score
      max = 0
      (0..(@grid.size-1)).each do |i|
        (0..(@grid[i].size-1)).each do |j|
          score = scenic_score(i, j)
          max = score if score > max
        end
      end
 
      max
    end

    private

    def viewing_distance(height, list)
      d = 0

      list.each do |tree|
        d += 1 if tree != -1

        break if tree >= height
      end

      d
    end

    def left(i, j)
      return [-1] if j == 0

      @grid[i][0..(j-1)].reverse
    end

    def right(i, j)
      return [-1] if j == @grid[i].size-1 

      @grid[i][(j+1)..-1]
    end

    def top(i, j)
      return [-1] if i == 0

      (i-1).downto(0).map { |pos| @grid[pos][j] }
    end

    def down(i, j)
      return [-1] if i == @grid.size-1 

      ((i+1)..(@grid.size-1)).map { |pos| @grid[pos][j] }
    end
  end


  class Day08
    def self.run(argv)
      forest = Forest.from_file(argv[0])

      puts "Part 1: #{forest.visible}"
      puts "Part 2: #{forest.max_scenic_score}"
    end
  end
end
