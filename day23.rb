module Advent2022

  Location = Struct.new(:row, :col) do
    def to_s
      "(#{self.row}, #{self.col})"
    end
  
    def move(shift)
      Location.new(self.row + shift.row, self.col + shift.col)
    end
  end

  class Elf
    attr_reader :id, :rule

    N  = Location.new(-1, 0).freeze
    S  = Location.new(1, 0).freeze
    W  = Location.new(0, -1).freeze
    E  = Location.new(0, 1).freeze
    NE = Location.new(-1, 1).freeze
    NW = Location.new(-1, -1).freeze
    SE = Location.new(1, 1).freeze
    SW = Location.new(1, -1).freeze

    RULES = [
      [ :N, :NE, :NW ],
      [ :S, :SE, :SW ],
      [ :W, :NW, :SW ],
      [ :E, :NE, :SE ]
    ].freeze
 
    def initialize(id)
      @id = id
      @rule = 0
    end

    def rules_a
      rules = []
      @rule.upto(@rule+3) { |i| rules << RULES[i % 4] }

      rules
    end

    def move_rule
      @rule = (@rule + 1) % 4
    end

    def shifts_from(loc)
      {
        n: loc.move(N),
        s: loc.move(S),
        w: loc.move(W),
        e: loc.move(E),
        ne: loc.move(NE),
        nw: loc.move(NW),
        se: loc.move(SE),
        sw: loc.move(SW)
      }
    end

    def to_s
      "Elf #{id}"
    end
  end

  class Ground
    INFINITY = 4294967295

    attr_reader :elves, :round

    def initialize
      @elves = {}
      @round = 0
    end

    def add_elf(elf, row, col)
      loc = Location.new(row, col)
      @elves[loc] = elf
    end


    def propose
      @proposals = {}
      @elves.each do |loc, elf|
        sug = elf_proposals(loc, elf)
        unless sug.nil?
          @proposals[sug] ||= []
          @proposals[sug] << loc
        end
      end
    end

    def move
      @round += 1
      moved = 0
      @proposals.each do |dest, elf_locations|
        if elf_locations.size == 1
          move_elf(elf_locations.first, dest)
          moved += 1
        else
          elf_locations.each do |loc|
            #puts "#{@elves[loc]} overlaps and won't move"
          end
        end
      end

      @elves.each { |loc, elf| elf.move_rule }

      moved
    end

    def limits
      rmin = cmin = INFINITY
      rmax = cmax = -INFINITY

      @elves.keys.each do |loc|
        rmin = loc.row if loc.row < rmin
        rmax = loc.row if loc.row > rmax
        cmin = loc.col if loc.col < cmin
        cmax = loc.col if loc.col > cmax
      end

      return rmin, cmin, rmax, cmax
    end
  
    def print
      puts
      puts area
      puts
    end

    def area
      rmin, cmin, rmax, cmax = limits
      width = cmax - cmin + 1
      rows = []
      i = rmin
      while i <= rmax do
        locs = @elves.keys.select { |loc| loc.row == i }
        row = Array.new(width, '.')
        locs.each do |loc|
          row[loc.col - cmin] = "#"
        end
        rows << row.join("")
        i += 1
      end

      rows.join("\n")
    end

    def empty_ground
      rmin, cmin, rmax, cmax = limits
      width = cmax - cmin + 1
      height = rmax - rmin + 1

      width*height - @elves.size
    end

    private

    def move_elf(origin, dest)
      elf = @elves.delete(origin)
      @elves[dest] = elf
    end

    def elf_proposals(loc, elf)
      directions = elf.shifts_from(loc)
      availability = check_availability(directions)
      free = availability.values.select { |v| v }.size
      #puts "  #{elf} at #{loc}: #{availability}. Free: #{free}"

      if free == 0 || free == 8
        #puts "  #{elf} at #{loc}. No propossals. Free: #{free}"
        return nil
      end

      elf.rules_a.each do |rule_trio|
        ok = true
        rule_trio.each do |rule|
          if !availability[rule.downcase]
            ok = false
            break
          end
        end
        if ok
          #puts "  #{elf} at #{loc}: #{rule_trio} = #{ok} => #{rule_trio.first}"
          return directions[rule_trio.first.downcase]
        end
      end  

      #puts "  #{elf} at #{loc} Nothing found"
      nil
    end

    def check_availability(dirs)
      available = {}
      dirs.each do |card, loc|
        available[card] = @elves[loc].nil?
      end

      available
    end
  end

  class UnstableDiffusion
  
    attr_reader :ground

    def initialize
      @ground = Ground.new
    end

    def add_elf(i, row, col)
      @ground.add_elf(Elf.new(i), row, col)
    end

    def self.from(data)
      data = File.read(data) if File.exist?(data)

      o = UnstableDiffusion.new
      i=0
      e = 0
      data.each_line do |line|
        line.strip.chars.each_with_index do |ch, j|
          if ch == '#'
            o.add_elf(e+1, i, j)
            e += 1
          end
        end
        i += 1
      end

      o
    end

    def round(n=1)
      n.times {
        @ground.propose
        @ground.move
      }
    end

    # To be used with no round called previously
    def rounds
      while true do
        @ground.propose
        moves = @ground.move
        return @ground.round if moves == 0
      end
    end

    def empty_ground
      @ground.empty_ground
    end

    def print
      @ground.print
    end
  end

  class Day23
    def self.run(argv)
      o = UnstableDiffusion.from(argv[0])
     
      o.round(10)
      puts "Part 1: #{o.empty_ground}"

      o = UnstableDiffusion.from(argv[0])
     
      starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      finished = o.rounds
      ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      puts "Part 2: #{finished}. Time elapsed: #{ending-starting} sec"
    end
  end
end
