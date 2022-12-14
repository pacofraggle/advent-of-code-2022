require 'set'

module Advent2022
  Coord = Struct.new(:x, :y) do
    def path_to(other)
      path = Set.new
      if self.x == other.x
        sides = [ self.y, other.y].sort!
        Range.new(sides[0], sides[1]).to_a.each do |i|
          path << Coord.new(self.x, i)
        end
      elsif self.y == other.y
        sides = [ self.x, other.x].sort!
        Range.new(sides[0], sides[1]).to_a.each do |i|
          path << Coord.new(i, self.y)
        end
      else
        raise 'Panic'
      end

      path
    end

    def self.coords(path)
      return if path.nil? || path.size == 0

      coords = Set.new
      coords << path[0]
      1.upto(path.size-1) do |i|
        path[i].path_to(path[i-1]).each { |c| coords << c }
      end

      coords.to_a
    end
  end

  class SparseCaveSlice
    INFINITY = 4294967295
    ROCK = "#"
    AIR = "."
    SAND = "o"
    INI = "+"

    def initialize(initial, add_floor=false)
      @floored = add_floor
      @obstacles = {} 
      @initial = initial

      mark(@initial, INI)
      @upper_left = Coord.new(INFINITY, 0)
      @lower_right = Coord.new(0, 0)
    end

    def add(path)
      Coord.coords(path).each { |c| mark(c, ROCK) }
    end

    def to_a
      close_map

      shift_x = @upper_left.x
      w = @lower_right.x - @upper_left.x + 1
      h = @lower_right.y + 1

      grid = Array.new(h)
      0.upto(h-1) { |row| grid[row] = Array.new(w, AIR) }

      @obstacles.each do |obs, _|
        grid[obs.y][obs.x - shift_x] = value(obs)
      end

      grid[grid.size-1] = Array.new(w, ROCK) if @floored

      grid
    end

    def to_s
      to_a.map { |row| row.join }.join("\n")
    end

    def print(range = nil)
      grid = to_a
      range = Range.new(0, to_a.size-1) unless range
      range.to_a.each { |row| puts grid[row].join }
    end

    def sand_amount
      @obstacles.select { |_, v| v == SAND }.count
    end

    def close_map
      return if @closed
      return unless @floored

      @lower_right.y = @lower_right.y + 2
      @closed = true
    end

    def sand(n=1)
      close_map

      1.upto(n) do |i|
        return i unless fall(@initial)
      end

      n
    end

    def spill_sand
      close_map
      room = true
      i = 0
      while room do
        i += 1
        room = fall(@initial)
      end

      i-1
    end

    def overflow_sand
      close_map
      i = 0
      while true do # ungh!!
        i += 1
        break if fall(@initial) == @initial
      end

      i
    end

    private

    def fall(coord)
      down = Coord.new(coord.x, coord.y+1)
      return false if out?(down)
      return fall(down) if available?(down)

      downleft = Coord.new(coord.x-1, coord.y+1)
      return false if out?(downleft)
      return fall(downleft) if available?(downleft)

      downright = Coord.new(coord.x+1, coord.y+1)
      return false if out?(downright)
      return fall(downleft) if available?(downleft)
      return fall(downright) if available?(downright)

      mark(coord, SAND)
      coord
    end

    def out?(c)
      return false if @floored

      c.x < @upper_left.x || c.x > @lower_right.x || c.y < @upper_left.y || c.y > @lower_right.y
    end

    def available?(c)
      v = value(c)
      v == AIR || v == INI
    end

    def value(c)
      return ROCK if @floored && c.y == @lower_right.y

      v = @obstacles[c]

      v.nil? ? AIR : v
    end

    def mark(coord, elm)
      @obstacles[coord] = elm

      if elm == ROCK
        @upper_left.x = coord.x if coord.x < @upper_left.x 
        @upper_left.y = coord.y if coord.y < @upper_left.y
        @lower_right.x = coord.x if coord.x > @lower_right.x 
        @lower_right.y = coord.y if coord.y > @lower_right.y
      elsif elm == SAND
        @upper_left.x = coord.x if coord.x < @upper_left.x 
        @lower_right.x = coord.x if coord.x > @lower_right.x 
      end
    end
  end

  class RegolithReservoir
    attr_reader :cave

    def initialize(cave)
      @cave = cave
    end

    def self.from(data, add_floor=false)
      data = File.read(data) if File.exist?(data)

      paths = []
      data.each_line do |line|
        l = line.strip
        path = l.split(/ -> /).map do |p|
          a, b = p.split(/,/)
          Coord.new(a.to_i, b.to_i)
        end
        paths << path
      end

      cave = SparseCaveSlice.new(Coord.new(500, 0), add_floor)
      paths.each { |path| cave.add(path) }
      
      RegolithReservoir.new(cave)
    end

    def spill
      @cave.spill_sand
    end

    def overflow
      @cave.overflow_sand
    end
  end

  class Day14
    def self.run(argv)
      rr = RegolithReservoir.from(argv[0])
      #rr.cave.print
      units = rr.spill
      #rr.cave.print
      puts "Part1: #{units}"

      rr = RegolithReservoir.from(argv[0], true)
      #rr.cave.print
      units = rr.overflow
      #rr.cave.print
      puts "Part2: #{units}"
    end
  end
end
