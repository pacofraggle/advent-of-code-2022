require 'yaml'

module Advent2022
  class CatodeRay

    class CRT
      def initialize
        @crt = [
          Array.new(40, '.'),
          Array.new(40, '.'),
          Array.new(40, '.'),
          Array.new(40, '.'),
          Array.new(40, '.'),
          Array.new(40, '.')
        ]

      end

      def apply(cycle, value)
        r = row_for(cycle)
        c = col_for(cycle)
        window = Range.new(value-1, value+1)

        #puts "(#{r}, #{c}): cycle=#{cycle} X=#{value} | #{window} #{window.include?(c)}"
        @crt[r][c] = "#" if window.include?(c)

        #puts row(r)
        #print
      end

      def col_for(cycle)
        (cycle-1) % 40
      end

      def row_for(cycle)
        (cycle-1) / 40
      end

      def row(r)
        @crt[r].join
      end

      def print
        puts
        puts to_s
        puts
      end

      def to_s
        s = ""
        @crt.each { |row| s += row.join + "\n" }

        s
      end
    end

    def initialize
      @crt = CRT.new
      @x =[0]
      @x << 1
    end

    def self.from_file(name)
      r  = CatodeRay.new

      File.readlines(name).each do |line|
        r.read_line(line)
      end

      r
    end

    def read_line(line)
      op, value_s = line.strip.split(/ /)

      if op == 'noop'
        noop
      elsif op == 'addx'
        addx(value_s.to_i)
      end
    end

    def noop
      #puts "noop"
      apply_pixel
      @x << @x[-1]
      #puts @x.to_s
    end

    def addx(value)
      #puts "addx #{value}"
      apply_pixel
      @x << @x[-1]
      apply_pixel
      @x << @x[-1] + value
      #puts @x.to_s
    end

    def X(cycle)
      @x[cycle]
    end

    def signal_strength(cycle)
      cycle * X(cycle)
    end

    def signal_strength_sum(cycles)
      cycles.reduce(0) { |acc, c| acc + signal_strength(c) }
    end

    def crt_row(r)
      @crt.row(r)
    end
      
    def crt
      @crt.to_s
    end

    private

    def apply_pixel
      cycle = @x.size-1
      @crt.apply(cycle, X(cycle))
    end
  end

  class Day10
    def self.run(argv)
      cr = CatodeRay.from_file(argv[0])

      puts "Part 1: #{cr.signal_strength_sum([20, 60, 100, 140, 180, 220])}"
      puts "Part 2:"
        puts cr.crt

    end
  end
end
