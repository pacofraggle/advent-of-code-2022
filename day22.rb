require 'pry'

module Advent2022
  class Path
    RIGHT = 0
    DOWN = 1
    LEFT = 2
    UP = 3

    attr_reader :description

    def initialize(description)
      @description = description
    end

    def self.dir_s(dir)
      d = case dir
          when RIGHT
            ">"
          when LEFT
            "<"
          when UP
            "^"
          when DOWN
            "v"
          end
      d
    end

    def self.turn_right(dir)
      (dir + 1) % 4
    end

    def self.turn_left(dir)
      (dir - 1) % 4
    end

    def steps(starting_dir=Path::RIGHT)
      @description.gsub(/R/, " turn_right ").gsub(/L/, " turn_left ").split(/ /)
    end
  end

  PositionValue = Struct.new(:row, :col, :value) do
    def to_s
      "(#{row}, #{col})=#{value}"
    end
  end

  class Map
    attr_reader :closed

    def initialize
      @rows = []
      @closed = false
    end

    def cell(row, col)
      @rows[row-1][col-1]
    end

    def set_cell(row, col, value)
      @rows[row-1][col-1] = value
    end

    def up_of(row, col)
      r = row - 2
      c = col - 1

      r = @rows.size - 1 if r < 0 || @rows[r][c] == " "

      v = @rows[r][c]
      while v == " " do
        r -= 1
        v = @rows[r][c]
      end

      return PositionValue.new(r+1, c+1, v), nil
    end

    def down_of(row, col)
      r = row
      c = col - 1

      r = 0 if r == @rows.size || @rows[r][c] == " "

      v = @rows[r][c]
      while v == " " do
        r += 1
        v = @rows[r][c]
      end

      return PositionValue.new(r+1, c+1, v), nil
    end

    def right_of(row, col)
      r = row - 1
      c = col

      c = 0 if c == @rows[r].size || @rows[r][c] == " "

      v = @rows[r][c]
      while v == " " do
        c += 1
        v = @rows[r][c]
      end

      return PositionValue.new(r+1, c+1, v), nil
    end

    def left_of(row, col)
      r = row - 1
      c = col - 2

      c = @rows[r].size - 1 if c < 0 || @rows[r][c] == " "

      v = @rows[r][c]
      while v == " " do
        c -= 1
        v = @rows[r][c]
      end

      return PositionValue.new(r+1, c+1, v), nil
    end

    def starting_point
      @rows[0].chars.each_with_index do |val, i|
        return PositionValue.new(1, i+1, val) if val == "."
      end
    end

    def <<(line)
      raise 'No can do' if @closed

      @rows << line
    end

    def close
      @closed = true

      width = @rows.map {|row| row.size }.max
      0.upto(@rows.size-1) { |i| @rows[i] = @rows[i].ljust(width, ' ') }
    end

    def print
      puts
      puts "+#{"-".ljust(@rows[0].size, "-")}+"
      @rows.each { |row| puts "|#{row}|" }
      puts "+#{"-".ljust(@rows[0].size, "-")}+"
    end
  end

  class CubicMap < Map
    def initialize(sector_size)
      super()

      @sector_size = sector_size
    end

    def set_warp(warp)
      @warp = warp
    end

    def up_of(row, col)
      irow, icol = internal(row, col)
      #puts "up_of(#{irow}, #{icol})..."
      current_sector_id = sector_id(irow, icol)
      raise "unknown sector for #{irow}, #{icol}" if current_sector_id.nil?
      r = irow - 1
      c = icol
      new_sector_id = sector_id(r, c) || @warp.neighbour(current_sector_id, Path::UP)

      if current_sector_id == new_sector_id
        return PositionValue.new(r+1, c+1, @rows[r][c]), Path::UP
      end

      current_sector = sector(current_sector_id)
      new_sector = sector(new_sector_id)
      new_direction = @warp.direction(current_sector_id, new_sector_id)
      #puts "up_of #{r}, #{c} - #{current_sector_id} -> #{new_sector_id} changing to #{new_direction}"
      delta = icol - current_sector.cmin
      if new_direction == Path::UP
        r = new_sector.rmax
        c = new_sector.cmin + delta
      elsif new_direction == Path::RIGHT
        r = new_sector.rmin + delta
        c = new_sector.cmin
      elsif new_direction == Path::LEFT
        r = new_sector.rmax - delta
        c = new_sector.cmax
      elsif new_direction == Path::DOWN
        r = new_sector.rmin
        c = new_sector.cmax - delta
      end

      return PositionValue.new(r+1, c+1, @rows[r][c]), new_direction
    end

    def down_of(row, col)
      irow, icol = internal(row, col)
      #puts "down_of(#{irow}, #{icol})..."
      current_sector_id = sector_id(irow, icol)
      raise "unknown sector for #{irow}, #{icol}" if current_sector_id.nil?
      r = irow + 1
      c = icol
      new_sector_id = sector_id(r, c) || @warp.neighbour(current_sector_id, Path::DOWN)

      if current_sector_id == new_sector_id
        return PositionValue.new(r+1, c+1, @rows[r][c]), Path::DOWN
      end

      current_sector = sector(current_sector_id)
      new_sector = sector(new_sector_id)
      new_direction = @warp.direction(current_sector_id, new_sector_id)
      #puts "down_of #{r}, #{c} - #{current_sector_id} -> #{new_sector_id} changing to #{new_direction}"
      delta = icol - current_sector.cmin
      if new_direction == Path::UP
        r = new_sector.rmax
        c = new_sector.cmax - delta
      elsif new_direction == Path::RIGHT
        r = new_sector.rmax - delta
        c = new_sector.cmin
      elsif new_direction == Path::LEFT
        r = new_sector.rmin + delta
        c = new_sector.cmax
      elsif new_direction == Path::DOWN
        r = new_sector.rmin
        c = new_sector.cmin + delta
      end
  
      return PositionValue.new(r+1, c+1, @rows[r][c]), new_direction
    end

    def right_of(row, col)
      irow, icol = internal(row, col)
      #puts "right_of(#{irow}, #{icol})..."
      current_sector_id = sector_id(irow, icol)
      raise "unknown sector for #{irow}, #{icol}" if current_sector_id.nil?
      r = irow
      c = icol + 1
      new_sector_id = sector_id(r, c) || @warp.neighbour(current_sector_id, Path::RIGHT)

      if current_sector_id == new_sector_id
        return PositionValue.new(r+1, c+1, @rows[r][c]), Path::RIGHT
      end

      current_sector = sector(current_sector_id)
      new_sector = sector(new_sector_id)
      new_direction = @warp.direction(current_sector_id, new_sector_id)
      #puts "right_of #{r}, #{c} - #{current_sector_id} -> #{new_sector_id} changing to #{new_direction}"
      delta = irow - current_sector.rmin
      if new_direction == Path::UP
        r = new_sector.rmax
        c = new_sector.cmin + delta
      elsif new_direction == Path::RIGHT
        r = new_sector.rmin + delta
        c = new_sector.cmin
      elsif new_direction == Path::LEFT
        r = new_sector.rmax - delta
        c = new_sector.cmax
      elsif new_direction == Path::DOWN
        r = new_sector.rmin
        c = new_sector.cmax - delta
      end
  
      return PositionValue.new(r+1, c+1, @rows[r][c]), new_direction
    end

    def left_of(row, col)
      irow, icol = internal(row, col)
      #puts "left_of(#{irow}, #{icol})..."
      current_sector_id = sector_id(irow, icol)
      raise "unknown sector for #{irow}, #{icol}" if current_sector_id.nil?
      r = irow
      c = icol - 1
      new_sector_id = sector_id(r, c) || @warp.neighbour(current_sector_id, Path::LEFT)

      if current_sector_id == new_sector_id
        return PositionValue.new(r+1, c+1, @rows[r][c]), Path::LEFT
      end

      current_sector = sector(current_sector_id)
      new_sector = sector(new_sector_id)
      new_direction = @warp.direction(current_sector_id, new_sector_id)
      #puts "left_of #{r}, #{c} - #{current_sector_id} -> #{new_sector_id} changing to #{new_direction}"
      delta = irow - current_sector.rmin
      if new_direction == Path::UP
        r = new_sector.rmax
        c = new_sector.cmax - delta
      elsif new_direction == Path::RIGHT
        r = new_sector.rmax - delta
        c = new_sector.cmin
      elsif new_direction == Path::LEFT
        r = new_sector.rmin + delta
        c = new_sector.cmax
      elsif new_direction == Path::DOWN
        r = new_sector.rmin
        c = new_sector.cmin + delta
      end

      return PositionValue.new(r+1, c+1, @rows[r][c]), new_direction
    end

    def close
      super

      prepare_sectors
    end

    private

    def internal(row, col)
      return row-1, col-1
    end

    def sector_id(row, col)
      @sectors.each_with_index do |sector, i|
        return i+1 if sector.include?(row, col)
      end

      nil
    end

    def sector(id)
      @sectors[id-1]
    end

    def prepare_sectors
      @sectors = []
      i=0
      while i < @rows.size
        j = 0
        while j < @rows[i].size
          if @rows[i][j] != " "
            @sectors << Sector.new(i, j, i + @sector_size-1, j + @sector_size-1)
          end
          j += @sector_size
        end
        i += @sector_size
      end
    end
  end

  Sector = Struct.new(:rmin, :cmin, :rmax, :cmax) do
    def include?(row, col)
      row >= self.rmin && row <= self.rmax && col >= self.cmin && col <= cmax
    end
  end

  class WarpSetup
    def initialize
      @neighbours = {}
      @directions = {}
    end

    def add(sector, neighbours, directions)
      @neighbours[sector] = neighbours
      @directions[sector] = directions
    end

    def neighbour(sector, dir)
      @neighbours[sector][dir]
    end

    def direction(origin, dest)
      @directions[origin][dest-1]
    end
  end

  class Route
    MOVES = [:right_of, :down_of, :left_of, :up_of].freeze

    def initialize(map, moves)
      @map = map
      @moves = moves.steps
    end

    def follow
      p = @map.starting_point
      dir = Path::RIGHT

      @moves.each do |move|
        if move.start_with?("turn")
          turn = move.to_sym
          dir = Path.send(turn, dir)
        else
          p, dir = dest(p, move.to_i, dir)
        end
      end

      #@map.print
      return p, dir
    end

    def password
      p, dir = follow

      p.row*1000 + p.col*4 + dir
    end

    private

    def dest(position, amount, dir)
      p = position
      action = MOVES[dir]
      amount.times do |i|
        @map.set_cell(p.row, p.col, Path.dir_s(dir))
        #@map.print
        d, new_dir = @map.send(action, p.row, p.col)
        break if d.value == "#"
        return p if d.value == "#"
        unless new_dir.nil? || new_dir == dir
          dir = new_dir
          action = MOVES[dir]
        end

        p = d
      end

      return p, dir
    end
  end

  class MonkeyMap
    attr_reader :map, :path

    def initialize(cube=nil)
      @map = !cube.nil? ? CubicMap.new(cube) : Map.new
    end

    def path=(line)
      @path = Path.new(line)
    end

    def add_row(line)
      @map << line
    end

    def self.from(data, cube = nil)
      data = File.read(data) if File.exist?(data)

      o = MonkeyMap.new(cube)
      empty = false
      data.each_line do |line|
        l = line.rstrip

        if empty
          o.path = l
        else
          if l.size == 0
            empty = true
          else
            o.add_row(l)
          end
        end
      end

      o.map.close

      o
    end

    def follow
      route = Route.new(map, path)

      route.follow
    end

    def password
      route = Route.new(map, path)

      route.password
    end
  end

  class Day22
    def self.run(argv)
      o = MonkeyMap.from(argv[0])
     
      puts "Part 1: #{o.password}"
      #o.map.print

      o = MonkeyMap.from(argv[0], 50)
      w = WarpSetup.new
      w.add(1, [2, 3, 4, 6], [-1, 0, 1, 0, -1, 0])
      w.add(2, [5, 3, 1, 6], [2, -1, 2, -1, 2, 3])
      w.add(3, [2, 5, 4, 1], [3, 3, -1, 1, 1, -1])
      w.add(4, [5, 6, 1, 3], [0, -1, 0, -1, 0, 1])
      w.add(5, [2, 6, 4, 3], [-1, 2, 3, 2, -1, 2])
      w.add(6, [5, 2, 1, 4], [1, 1, -1, 3, 3, -1])
      o.map.set_warp(w)
 
      puts "Part 2: #{o.password}"
    end
  end
end
