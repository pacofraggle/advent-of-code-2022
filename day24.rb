require 'pry'
require 'set'
require 'io/console'

module Advent2022
  class Valley
    MOVES = {
      'v' => [1, 0],
      '^' => [-1, 0],
      '<' => [0, -1],
      '>' => [0, 1]
    }.freeze

    class Node 
      attr_accessor :t, :location, :neighbours

      def initialize(t, location)
        @t = t
        @location = location
        @neighbours = []
      end

      def add_neighbour(neighbour)
        @neighbours << neighbour
      end
    end

    Location = Struct.new(:row, :col, :valley) do
      def to_s
        "(#{row}, #{col})" 
      end

      def can_move?(shift_row, shift_col)
        rt = row + shift_row
        ct = col + shift_col

        (rt == valley.exit.row && ct == valley.exit.col) || (rt == valley.start.row && ct == valley.start.col) || 
        (rt >= valley.rmin && rt <= valley.rmax && ct >=valley.cmin && ct <= valley.cmax)
      end

      def move(shift_row, shift_col)
        return false unless can_move?(shift_row, shift_col)

        row += shift_row
        col += shift_col

        true
      end

      def alternative(shift_row=0, shift_col=0)
        return false unless can_move?(shift_row, shift_col)

        Location.new(row + shift_row, col + shift_col, valley)
      end

      def dexit
        # TODO: cache this?
        (row - valley.exit.row).abs + (col - valley.exit.col).abs
      end
    end

    class Blizzard
      attr_reader :type, :origin
      attr_accessor :current

      def initialize(type, origin)
        @type = type
        @origin = Location.new(origin.row, origin.col, origin.valley)
        @valley = origin.valley
        @current = Location.new(origin.row, origin.col, origin.valley)
      end

      def move(t=1)
        min.times { |t| shift }
      end

      def shift
        shift = Valley::MOVES[@type]
        @current.row += shift[0]
        @current.col += shift[1]
        @current.col = @valley.cmin if @current.col > @valley.cmax
        @current.col = @valley.cmax  if @current.col < @valley.cmin
        @current.row = @valley.rmin if @current.row > @valley.rmax
        @current.row = @valley.rmax  if @current.row < @valley.rmin

        return @current.row, @current.col
      end

      def to_s
        "#{type} at #{current}"
      end
    end

    attr_reader :blizzards, :rmin, :rmax, :cmin, :cmax, :start, :exit

    def initialize
      @rows = []
      @blizzards = []
      @elf = nil
    end

    def add_elf
      @elf = @start.dup
    end

    def blank_row
      "#"+".".ljust(cmax, ".")+"#"
    end

    def add(line)
      if line.chars.count("#") > 2
        @rows << line
        set_accesses(line)
      else
        @rows << blank_row.clone
        set_blizzards(line)
      end
    end

    def minutes_to_exit
      nodes = []
      nodes[0] = [Node.new(0, @start)]
      t = 1
      exit_found = false
      until exit_found do
        recalculate_blizzards
        nodes[t] = moves_from(t, nodes[t-1])

        if nodes[t].size == 0
          binding.pry
        end
        exit_found = !(nodes[t].find { |n| n.location.dexit == 0 }).nil?

        #puts "t=#{t} : #{nodes[t].size}"
        t += 1
      end

      t - 1
    end
    
    def flip_dest
      temp = @exit
      @exit = @start
      @start = temp
    end

    def moves_from(t, safe_nodes)
      available = {}
      all = []
      safe_nodes.each do |spot|
        opts = candidates_from(spot)
        opts.each do |opt| 
          if available.dig(opt.row, opt.col)
            node = available[opt.row][opt.col]
          else
            node = Node.new(t, opt)
            available[opt.row] ||= {}
            available[opt.row][opt.col] = node
            all << node
          end

          spot.add_neighbour(node)
        end
      end

      all.sort_by { |p| p.location.dexit }
    end

    def candidates_from(node)
      viable = []
      if available?(node.location) #&& node.location != @start
        viable << node.location.alternative
      end
      MOVES.each do |desc, shift|
        row, col = *shift
        alt = node.location.alternative(row, col)

        viable << alt if alt && alt != @start && available?(alt)
      end

      viable
    end

    def recalculate_blizzards
      rmin.upto(rmax) { |i| @rows[i] = blank_row.clone }
     
      @blizzards.each do |b|
        b.shift
        @rows[b.current.row][b.current.col] = "#"
      end
    end

    def available?(location)
      @rows[location.row][location.col] == "."
    end

    def area
      @area = []
      @rows.each { |row| @area << row.dup }
      @blizzards.each do |b|
        pos = b.current
        current = @area[pos.row][pos.col] 
        @area[pos.row][pos.col] = if current == '.'
                                    b.type
                                  elsif MOVES.keys.include?(current)
                                    "2"
                                  else
                                    (@area[pos.row][pos.col].to_i + 1).to_s
                                  end
      end
      if @elf
        @area[@elf.row][@elf.col] = "E"
      end

      @area
    end

    def print
      puts
      area.each { |row| puts row }
    end
    
    private

    def set_blizzards(line)
      i = @rows.size - 1
      line.chars.each_with_index do |ch, j|
        if ch != "#" && ch != "."
          @blizzards << Blizzard.new(ch, Location.new(i, j, self))
        end
      end
    end

    def set_accesses(line)
      access = 0
      line.chars.each_with_index do |ch, j|
        if ch == "."
          access = j
          break
        end
      end

      if @rows.size == 1
        @cmin ||= 1
        @rmin ||= 1
        @cmax ||= @rows[0].size-2

        @start = Location.new(0, access, self)
      else
        @rmax ||= @rows.size-2

        @exit = Location.new(@rows.size-1, access, self)
      end
    end
  end

  class BlizzardBasin
    attr_reader :valley

    def initialize
      @valley = Valley.new
    end

    def add_line(line)
      @valley.add(line)
    end

    def reach_goal
      valley.minutes_to_exit
    end

    def self.from(data)
      data = File.read(data) if File.exist?(data)

      o = BlizzardBasin.new
      data.each_line do |line|
        l = line.strip
        o.add_line(l)
      end

      o
    end
  end

  # The visualization is broken and I totally removed the tests
  # For the solution I simply built a graph with the path that gets
  # discovered after each minute
  # I was planning to used Dijkstra to traverse the graph, but it is enough
  # with the time to find an exit
  #
  # For part two, switching the start and exit did it
  # I think this got speeded up when I realized that there were
  # many more blizzards than empty spaces
  # At that moment I decided to create "snapshots" of the map instead of
  # comparing against the full +2600 blizzards
  class Day24
    def self.run(argv)
      o = BlizzardBasin.from(argv[0])

      reach_goal = o.reach_goal
      puts "Part 1: #{reach_goal}"

      o.valley.flip_dest
      go_back = o.reach_goal
      puts "  ... go back, get the snacks: #{go_back}"
      o.valley.flip_dest
      exit_again = o.reach_goal
      puts "  ... return to the exit: #{exit_again}"

      puts "Part 2: #{reach_goal+go_back+exit_again}"
    end
  end
end
