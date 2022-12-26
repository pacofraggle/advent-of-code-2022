require 'pry'
module Advent2022
  class Shape
    attr_reader :shape, :name

    def initialize(name, shape)
      @shape = shape
      @name = name
    end

    class << self
      def square
        Shape.new(:o, [[1, 1], [1, 1]])
      end

      def vbar
        Shape.new(:i, [[1], [1], [1], [1]])
      end

      def iel
        Shape.new(:l, [[1, 1, 1], [0, 0, 1], [0, 0, 1]])
      end

      def cross
        Shape.new(:x, [[0, 1], [1, 1, 1], [0, 1]])
      end

      def hbar
        Shape.new(:m, [[1, 1, 1, 1]])
      end
    end
  end

  class Cave
    class Rock
      attr_accessor :x, :y, :shape

      def initialize(shape)
        @shape = shape
      end

      def set(x, y)
        @x = x
        @y = y
      end

      def shape
        @shape.shape
      end

      def name
        @shape.name
      end
    end

    def initialize(prune = false)
      @rows = Array.new
      @prune = prune
      @min = 0
      @trimmed = 0
    end

    def add_row(row)
      @rows << row
    end
 
    def set_row(i, row)
      if i<=top
        @rows[i] = row
      else
        add_row(row)
      end
    end

    def trim_cave(min)
      return if min == -1

      (min+1).times { @rows.shift }
      @trimmed += min + 1
    end

    def blank_row
      [1, 0, 0, 0, 0, 0, 0, 0, 1]
    end

    def top
      @rows.size-1
    end

    def height
      top + 1 + @trimmed
    end

    def row(i)
      i<=top && !@rows[i].nil? ? @rows[i] : blank_row
    end

    def add_rock(rock)
      @falling = rock
      @falling.set(3, top+4)
    end

    def move(dir)
      @falling.shape.each_with_index do |rock_row, i|
        cave = row(@falling.y + i).clone
        rock_row.each_with_index do |elm, j|
          pos = @falling.x + j + dir
          if pos < cave.size
            cave[pos] += elm 
            return false unless cave[pos] <= 1
          end
        end
      end

      @falling.x += dir
      true
    end

    def fall
      sit = false
      if @falling.y < 1
        sit = true
      else
        @falling.shape.each_with_index do |rock_row, i|
          cave = row(@falling.y + i - 1).clone
          rock_row.each_with_index do |elm, j|
            pos = @falling.x + j
            if pos < cave.size
              cave[pos] += elm 
              if cave[pos] > 1
                sit = true
                break
              end
            end
          end
          break if sit
        end
      end

      if sit
        sit_falling
        false
      else
        @falling.y -= 1
        true
      end
    end

    def sit_falling
      full = []
      @falling.shape.each_with_index do |rock_row, i|
        cave = row(@falling.y + i).clone
        rock_row.each_with_index do |elm, j|
          pos = @falling.x + j
          cave[pos] += elm if pos < cave.size
        end
        set_row(@falling.y + i, cave)
        full << @falling.y + i if cave.sum == 9
      end
      @falling = nil

      trim_cave(full.max) if @prune && !full.empty?
    end

    def print(n=nil)
      puts
     
      @board = Array.new
      h = [top]
      if @falling
        h << @falling.y + @falling.shape.size - 1
      end

      @rows.each do |row|
        @board << row.clone
      end
      @rows.size.upto(h.max) { |_| @board << blank_row }
      
      if @falling
        @falling.shape.each_with_index do |rock_row, i|
          rock_row.each_with_index do |value, j|
            @board[@falling.y + i][@falling.x + j] = "@" if value > 0
          end
        end
      end
      n = n.nil? ? @board.size : n
      @board.reverse.each_with_index do |row, i|
        puts row.join("").gsub(/0/, ".").gsub(/1/, "#")
        if i == n
          puts "..."
          break
        end
      end
      puts "#########"
      puts @floor.to_s
      puts
    end
  end

  class PyroclasticFlow
  
    SHAPE_SEQ = [ Shape.hbar, Shape.cross, Shape.iel, Shape.vbar, Shape.square ]

    attr_reader :cave

    def initialize(pattern, prune=false)
      @rock = 0
      @flow = -1
      @jet = pattern
      @estimating = false

      @cave = Cave.new(prune)

    end

    def estimate
      @estimating = true
      prepare_stats
    end

    def self.from(data, prune = false)
      data = File.read(data) if File.exist?(data)

      l = data.strip
      PyroclasticFlow.new(l, prune)
    end

    def play(n=1)
      @estimate = n if @estimating
      estimation = nil
      1.upto(n) do |i|
        estimation = free_throw(i)

        break unless estimation.nil? 
      end

      if @estimating
        return estimation if estimation
        calculate_estimation
      else
        cave.height
      end
    end

    private

    def prepare_stats
      @estimate = -1

      @seqs = [-1]
      @seqs_data = [{}]
      reset_cycle
    end

    def reset_cycle
      #puts "Reseting a #{@repeated} cycle"
      @repeated = 0
      @rep_start = -1
      @rep_end = -1
      @rep_start_value = -1
    end

    # It should be enough with finding a previous occurence of current_flow. That'd speed up things considerably
    # Here I'm checking that the cycle is totally equal. Once done, an estimation is calculated
    def record(current_piece, current_rock, current_flow, height)
      @seqs << current_flow
      @seqs_data << { iteration: current_piece, rock: current_rock, height: height }

      if @rep_start == -1
        prev = nil
        (@seqs.size-2).downto(1) do |i|
          if @seqs[i] == current_flow && @seqs_data[i][:rock] == current_rock
            @rep_start = i
            @rep_end = @seqs.size-2
            @rep_start_value = current_flow
            @repeated = 1
            #puts "Starting a #{current_rock} cycle check at #{i} (of size #{@rep_end-@rep_start})"
            break
          end
        end
        return
      end

      if @seqs[@rep_start + @repeated] == current_flow
        if @repeated + @rep_start - 1 == @rep_end
          #return calculate_estimation
          div, mod = calculate_estimation
          return div if mod == 0

          reset_cycle
        else
          @repeated += 1
        end
      else
        reset_cycle
      end

      nil
    end

    # Here is how this works:
    #  We've found a cycle, but after it0 iterations in a h0 high cave
    #  We want to see how many cycles we need to fill that remaining space
    #    so we're missing estimate-it0 / cycle_size cycles
    #  Once we have that, the estimated h = h0 + cycles x cycle_height
    #
    #  However, that division needs to be even. We will repeat with a
    #    different h0 until that happens
    #    In the input, the remainder gets smaller each time
    def calculate_estimation
      a = @seqs_data[@rep_start]
      b = @seqs_data[@rep_end+1]

      it0 = @seqs_data[@rep_start-1][:iteration]
      h0 = a[:height]

      #puts a.to_s
      #puts b.to_s

      dh = b[:height] - a[:height]
      dp = b[:iteration] - a[:iteration]

      reps, mod = (@estimate - it0).divmod(dp)

      est = h0 + reps*dh

      [est, mod]
    end

    def next_rock
      shape = SHAPE_SEQ[@rock % SHAPE_SEQ.size]
      @rock += 1

      Cave::Rock.new(shape)
    end

    def next_flow
      @flow = (@flow + 1) % @jet.size
      dir = @jet[@flow]

      dir == "<" ? -1 : 1
    end

    def free_throw(current_piece)
      fall = true
      rock = next_rock
      cave.add_rock(rock)
      if @estimating
        estimation = record(current_piece, rock.name, @flow, cave.height)
        return estimation unless estimation.nil?
      end
      while fall do
        dir = next_flow
        moved = cave.move(dir)
        fall = cave.fall
      end

      nil
    end
  end

  # Part 1 was a delight, part 2 a torture
  # I started trying to optimize the cave by trying to deal with shapes
  #   or finding the lowest floor.
  # All those efforts were in vain, as the number of iterations expected
  #   was too large.
  # I ended up trimming below full lines. That proved to be enough for
  #   the input file (the amount of memory needed was considerably lower
  # For the estimation I tried proportions. This was confusing, because
  #   I was getting very close values, however with a remainder
  # I tried to identify height patterns and falling sequence for different
  #   rocks to no avail.
  # In the end I decided for flow patterns, but It took me a good while
  #   to get to the final formula as I was mixing concepts from previous
  #   attempts 
  class Day17
    def self.run(argv)
      jet_pattern = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"
      o = PyroclasticFlow.from(argv[0])

      puts "Part 1: #{o.play(2022)}"

      o = PyroclasticFlow.from(jet_pattern, true)
      o.estimate
      puts "Part 2 (for example): #{o.play(1000000000000)}"


      o = PyroclasticFlow.from(argv[0], true)
      o.estimate
      starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      height = o.play(1000000000000)
      ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      puts "Part 2: #{height}. T. Elapsed: #{ending-starting} sec."
    end
  end
end
