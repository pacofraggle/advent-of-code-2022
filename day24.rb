require 'pry'
require 'set'
require 'io/console'

module Advent2022
  class Valley
    Location = Struct.new(:row, :col) do
      def to_s
        "(#{row}, #{col})" 
      end

      def up
        Location.new(row-1, col)
      end
      def down
        Location.new(row+1, col)
      end
      def left
        Location.new(row, col-1)
      end
      def right
        Location.new(row, col+1)
      end

      def d(other)
        (other.row - self.row).abs + (other.col - self.col).abs
      end

      def self.cache(dexit, width, height)
        @@dexit = Array.new(width)
        0.upto(width-1) { |i| @@dexit[i] = Array.new(height) }
        @@dexit.each_with_index do |row, i|
          row.each_with_index do |cell, j|
           @@dexit[i][j] = (dexit.row - i).abs + (dexit.col - j).abs
          end
        end
      end

      def dexit
        @@dexit[self.row][self.col]
      end
    end

    class Blizzard
      MOVES = {
        'v' => [1, 0],
        '^' => [-1, 0],
        '<' => [0, -1],
        '>' => [0, 1]
      }.freeze

      attr_reader :type, :origin
      attr_accessor :current

      def initialize(type, origin)
        @type = type
        @origin = origin
        @current = @origin.dup
      end

      def move(min, rmin, cmin, rmax, cmax)
        @current = @origin.dup
        shift = MOVES[@type]
        min.times do |t|
          @current.row += shift[0]
          @current.col += shift[1]
          @current.col = 1 if @current.col > cmax
          @current.col = cmax  if @current.col < cmin
          @current.row= 1 if @current.row > rmax
          @current.row = rmax  if @current.row < rmin
        end
      end

      def shift(rmin, cmin, rmax, cmax)
        shift = MOVES[@type]
        @current.row += shift[0]
        @current.col += shift[1]
        @current.col = 1 if @current.col > cmax
        @current.col = cmax  if @current.col < cmin
        @current.row= 1 if @current.row > rmax
        @current.row = rmax  if @current.row < rmin
      end

      def to_s
        "#{type} at #{current}"
      end
    end

    INFINITY = 4294967295

    def initialize
      @rows = []
      @blizzards = []
      @elf = nil
    end

    def add_elf
      @elf = @start.dup
    end

    def add(line)
      if line.chars.count("#") > 2
        @rows << line
        set_accesses(line)
      else
        @rows << "#"+".".ljust(line.size-2, ".")+"#"
        set_blizzards(line)
      end
    end

    def at(min, path, shift=false)
      #puts "at #{min}----------"
      #puts path.to_s
      recalculate_blizzards(min, shift)
      #print
      success = move_elf(min, path)
      #print

      success
    end
    
    def move_elf(t, path)
      #puts "move_elf #{t}----------"

      # Reproducing
      if path[t]
        #puts path.values.map { |p| p.to_s }.join(", ")
        #puts "#{t}: Reproducing #{path[t]}"
        choice = path[t] #opts.select { |op| op == path[t] }.first

        raise 'Error' unless choice

        @elf.row = choice.row
        @elf.col = choice.col

        return true
      end

      opts = elf_options
      if opts.size == 0
        #puts "#{t}: No alternatives"
        return false 
      end

      # Only one way
      if opts.size == 1
        best = opts.first
        @elf.row = best.row
        @elf.col= best.col
        path[t] = best
        #puts "#{t}: OneWay #{path[t]}"

        return true
      end

      #puts alternativesputs 'Several options'
      best = choose_closest(opts)
      if best.size == 1
        #puts "Best is #{best}"
        best = best.first

        @elf.row = best.row
        @elf.col= best.col

        path[t] = best
        #puts "#{t}: Closest best #{path[t]}"

        return true
      end

      #puts 'Argh'
      #if path[min].nil?
      path[t] = best # Array
      #puts "#{t}: Various routes #{path[t]}"

      false
    end

    def choose_closest(opts)
      #min = opts.map { |opt| opt.d(@exit) }.min

      #opts.select { |o| o.d(@exit) == min }
      opts.sort_by { |opt| opt.dexit }
    end
    
    def routes
      Valley::Location.cache(@exit, @rows.size, @rows[0].size)
      q = []
      q << {}

      variants = Set.new
      explored = Set.new
      min_variant = INFINITY
      until q.empty? do
        path = q.shift

        if exit?(path)
          puts "Solution found #{path.size}"
          variants << path
          min_variant = [min_variant, path.size].min
          next
        end

        puts "Q size #{q.size}. Path: #{path.size} Packed: #{explored.size}" if q.size % 200 == 0 || explored.size % 500 == 0
        alternatives = get_out(path)

        next if alternatives.nil?

        alternatives.each do |alt|
          next if alt.size > min_variant

          if !explored.include?(alt)
            explored << alt

            found = q.find { |elm| equivalent?(alt, elm) }
            q << alt unless found
          end
        end
      end

      variants
    end

    def prune_equivalents(q)
      list = q.to_a
      
      list.each_with_index do |elm, i|
        next if elm.nil?
        (i+1).upto(list.size-1) do |j|
          elm2 = list[j]
          next if elm2.nil?
          if equivalent?(elm, elm2)
            q.delete(list[j])
          end
        end
      end
    end

    def include?(path, explored)
      found = explored.find { |ex| equivalent?(path, ex) }

      !found.nil?
    end


    def equivalent?(path, other)
      min = [path.size, other.size].min

      t = path.keys.last

      path[t] == other[t]
    end


    def exit?(path)
      t = path.keys.last
      path[t] == @exit
    end

    def already_visited?(path, visited)
      selected = visited.select { |v| v.size >= path.size }
      selected.each do |sel|
        return true if equivalent?(path, sel)
      end

      false 
    end

    def trim(path, q)
      selected = q.select { |v| v.size <= path.size }
      save = []
      selected.each do |sel|
        save << sel unless equivalent?(sel, path)
      end

      save
    end


    def found(alt, variants)
      variants.each do |variant|
        min = [alt.size, variant.size].min
        equal = true
        0.upto(min-1) do |i|
          if variant[i] != alt[i]
            equal = false
            break
          end
        end
        return true if equal
      end

      false
    end

    def get_out(path = {})
      #puts "getout----------"
#binding.pry
      if path.empty?
        add_elf
        t = 1
      else
        t = path.keys.last
        @elf.row = path[t].row
        @elf.col = path[t].col
      end
      shift = false
      until @elf == @exit
        success = at(t, path, shift)
        shift = true
        t += 1
        next if success

        options = path[t-1]
        return nil if options.nil?  

        next unless options.is_a?(Array) 
        
        alts = []
        options.each do |op|
          pth = path.dup
          pth[t-1] = op
          alts << pth
        end
        path.delete(t-1)
#binding.pry if t > 8
        return alts
      end

#binding.pry
      [path.dup]
    end

    def recalculate_blizzards(min, shift)
      if shift
        @blizzards.each do |b|
          b.shift( 1, 1, @rows.size-2, @rows[0].size-2)
        end 
      else
        @blizzards.each do |b|
          b.move(min, 1, 1, @rows.size-2, @rows[0].size-2)
        end 
      end 
    end

    def elf_options
      down = @elf.down 
      return [down] if down == @exit

      viable = []
      viable << down if @elf.row < @rows.size-2
      viable << @elf.up if @elf.row > 1
      viable << @elf.right if @elf.col < @rows[0].size-1 && @elf != @start
      viable << @elf.left if @elf.col > 1 && @elf != @start
      viable << @elf.dup

      nearb = @blizzards.select do |b|
        b.current.row>=@elf.row-1 && b.current.row<=@elf.row+1 &&
        b.current.col>=@elf.col-1 && b.current.col<=@elf.col+1
      end
 
      chosen = []
      viable.each do |option|
        #puts " viable? #{option}"
        if nearb.find { |b| option == b.current }.nil?
          #puts "  #{option} is viable"
          chosen << option
        end
      end
      chosen
    end

    def reproduce_variant(path)
      add_elf
      $stdout.clear_screen
      t = 0
      until @elf == @exit
        puts path.map { |p, v| v.to_s }.join(", ")
        print
        t += 1
        success = at(t, path)
        #puts "Minute #{t} ==================="
        print
        raise 'Problem' unless success
        STDIN.getch
        $stdout.clear_screen
      end
    end

    def area
      @area = []
      @rows.each { |row| @area << row.dup }
      @blizzards.each do |b|
        pos = b.current
        current = @area[pos.row][pos.col] 
        @area[pos.row][pos.col] = if current == '.'
                                    b.type
                                  elsif Blizzard::MOVES.keys.include?(current)
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
          @blizzards << Blizzard.new(ch, Location.new(i, j))
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
        @start = Location.new(0, access)
      else
        @exit = Location.new(@rows.size-1, access)
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

    def find_routes
      routes = @valley.routes

      routes.each do |r|
        puts r.map { |p, v| v.to_s }.join(", ")
        #@valley.reproduce_variant(r)
      end
      routes.map { |r| r.size }.min
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

  class Day24
    def self.run(argv)
      o = BlizzardBasin.from(argv[0])

      puts o.find_routes
    end
  end
end
