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

    def initialize
      @rows = Array.new
      @rows << Array.new(9, 1)
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

    def blank_row
      [1, 0, 0, 0, 0, 0, 0, 0, 1]
    end

    def top
      @rows.size-1
    end

    def height
      top
    end

    def row(i)
      i<=top && !@rows[i].nil? ? @rows[i] : blank_row
    end

    def add_rock(rock)
      @falling = rock
      @falling.set(3, top+4)
    end

    def move(dir)
      dir = dir == "<" ? -1 : 1
      #puts "move #{dir}"
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
      #puts "fall"
      sit = false
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

      if sit
        sit_falling
        false
      else
        @falling.y -= 1
        true
      end
    end

    def sit_falling
      @falling.shape.each_with_index do |rock_row, i|
        cave = row(@falling.y + i).clone
        rock_row.each_with_index do |elm, j|
          pos = @falling.x + j
          cave[pos] += elm if pos < cave.size
        end
        set_row(@falling.y + i, cave)
        #if cave.sum == 9
        #  puts "Tetris found at #{@falling.y + i}"
        #end
      end

      @falling = nil
    end

    def print
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
 
      @board.reverse.each do |row|
        puts row.join("").gsub(/0/, ".").gsub(/1/, "#")
      end
      puts
    end
  end

  class PyroclasticFlow
  
    SHAPE_SEQ = [ Shape.hbar, Shape.cross, Shape.iel, Shape.vbar, Shape.square ]

    attr_reader :cave

    def initialize(pattern)
      @rock = 0
      @flow = 0
      @jet = pattern

      @cave = Cave.new
    end

    def next_rock
      shape = SHAPE_SEQ[@rock % SHAPE_SEQ.size]
      @rock += 1

      Cave::Rock.new(shape)
    end

    def next_flow
      dir = @jet[@flow % @jet.size]
      @flow+= 1

      dir
    end

    def self.from(data)
      data = File.read(data) if File.exist?(data)

      l = data.strip
      PyroclasticFlow.new(l)
    end

    def free_throw
      fall = true
      rock = next_rock
      cave.add_rock(rock)
      seq = rock.name.to_s
      while fall do
        dir = next_flow
        cave.move(dir)
        seq += dir
        #cave.print
        fall = cave.fall
        #cave.print
      end

      seq
    end

    def play(n=1)
      @seqs = {}
      #cave.print
      1.upto(n) do |i|
        puts "#{i} / #{cave.top} / #{cave.height} ---------------------------" if i % 100000 == 0
        seq = free_throw

        if @seqs[seq]
          #puts "#{i}: Repeated #{seq} #{@seqs[seq].size} at #{i} - #{cave.height}"
          puts "#{i} => #{cave.height*1000000000000/i}" if i % 10000 == 0
        end
        @seqs[seq] = i unless @seqs.size > 200
      end

      cave.height
    end

  end

  class Day17
    def self.run(argv)
      jet_pattern = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"
      #o = PyroclasticFlow.from(jet_pattern, true)
      o = PyroclasticFlow.from(argv[0])
     
      puts "Part 1: #{o.play(2022)}"

      #o = PyroclasticFlow.from(argv[0])
      #o = PyroclasticFlow.from(jet_pattern)
      #puts "Part 2: #{o.play(1000000000000)}"
      puts "Part 2: NOT YET"
    end
  end
end
