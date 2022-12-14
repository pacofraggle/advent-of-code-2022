require 'set'

module Advent2022
  Position = Struct.new(:x, :y) do
    def follow(lead, pos)
      return self if self == lead

      dx = lead.x-self.x
      dy = lead.y-self.y

      return self if dx.abs <= 1 && dy.abs <= 1

      raise 'Broken' if dx.abs > 2 || dy.abs > 2

      p = if dx.abs == 2 && dy == 0
        Position.new(self.x+dx/2, self.y)
      elsif dy.abs == 2 && dx == 0
        Position.new(self.x, self.y+dy/2) 
      elsif dy.abs == 2 && dx.abs == 1
        Position.new(self.x+dx, self.y+dy/2)
      elsif dy.abs == 1 && dx.abs == 2
        Position.new(self.x+dx/2, self.y+dy)
      elsif dy.abs == 2 && dx.abs == 2 # Required for part 2
        Position.new(self.x+dx/2, self.y+dy/2)
      else 
        raise "What? #{pos}: #{self} vs #{lead}"
      end

      p
    end

    def to_s
      "(#{self.x}, #{self.y})"
    end
  end

  class Rope

    def initialize(knots=2)
      @knots = []
      1.upto(knots).each do |_|
        @knots << Position.new(0, 0)
      end
      
      @tail_trace = Set.new
      add_tail_trace
      #print_panel("Initial")
    end

    def self.from_file(name, knots=2)
      r  = Rope.new(knots)

      File.readlines(name).each do |line|
        r.head_move_line(line)
      end

      r
    end

    def head_move_line(line)
      dir, count_s = line.strip.split(/ /)
      count = count_s.to_i

      1.upto(count).each { |i| move_head(dir) }
    end  

    def move_head(dir)
      case(dir)
      when 'R'
        @knots[0].x += 1
      when 'L'
        @knots[0].x -= 1
      when 'U'
        @knots[0].y += 1
      when 'D'
        @knots[0].y -= 1
      else
        raise 'Unknown move'
      end

      move_tails
      #print_panel("  move head #{dir}")
    end

    def head
      @knots[0].clone
    end

    def tail
      @knots[-1].clone
    end

    def trace_count
      @tail_trace.size
    end

    def print_panel(header)
      grid = Array.new(20)
      0.upto(grid.size-1) { |h| grid[h] = Array.new(20, '.') }
      
      @knots.each_with_index do |k, i|
        posx = k.x + 9
        posy = k.y + 9
        if i == 0
          grid[posy][posx] = 'H' 
        elsif grid[posy][posx] == '.'
          grid[posy][posx] = i.to_s
        end
      end

      puts header
      grid.reverse.each { |row| puts row.join }
      puts "Tail visits: #{trace_count} #{@tail_trace.map { |t| t.to_s }.join}"
    end

    private

    def move_tails
      1.upto(@knots.size-1) do |k|
        @knots[k] = @knots[k].follow(@knots[k-1], k)

      end
      add_tail_trace
    end

    def add_tail_trace
      @tail_trace << tail
    end
  end

  class Day09
    def self.run(argv)
      rope = Rope.from_file(argv[0])

      puts "Part 1: #{rope.trace_count}"

      rope = Rope.from_file(argv[0], 10)
      puts "Part 2: #{rope.trace_count}"
      end
  end
end
