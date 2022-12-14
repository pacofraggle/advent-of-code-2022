
module Advent2022
  class CleaningAssignments

    class Pair
      def initialize(a, b, x, y)
        @a = Range.new(a, b)
        @b = Range.new(x, y)
      end

      def covers?
        @a.cover?(@b) || @b.cover?(@a)
      end

      def intersect?
        shared = @a.to_a.find { |e| @b.include?(e) }

        !shared.nil?
      end

      def to_s
        "#{@a} / #{@b}"
      end
    end

    def initialize
      @pairs = []
    end

    def self.from_file(name)
      r  = CleaningAssignments.new

      File.readlines(name).each do |line|
        r.add_pair_line(line)
      end

      r
    end

    def add_pair_line(line)
      a, b = line.strip.split(/,/)

      a_ini, a_end = a.split(/-/)
      b_ini, b_end = b.split(/-/)
      @pairs << Pair.new(a_ini.to_i, a_end.to_i, b_ini.to_i, b_end.to_i)
    end  

    def covers
      @pairs.select do |pair|
        pair.covers?
      end
    end

    def overlaps
      @pairs.select do |pair|
        pair.intersect?
      end
    end
  end

  class Day04
    def self.run(argv)
      assignments = CleaningAssignments.from_file(argv[0])
      puts assignments.covers.count
      puts assignments.overlaps.count
    end
  end
end
