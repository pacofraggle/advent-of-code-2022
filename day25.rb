module Advent2022
  class Snafu
    def initialize(value)
      @value = value
      @integer = Snafu.s_to_i(@value)
    end

    class << self

      def i_to_s(integer)
        remainders = []

        div, mod = integer.divmod(5)
        remainders << mod
        until div == 0 do
          div, mod = div.divmod(5) 
          remainders << mod
        end
        
        changes = 1
        while changes > 0 do
          #puts "pass: #{remainders}"

          remainders.each_with_index do |r, i|
            if r == 3
              remainders[i] = [-2, 1]
            elsif r == 4
              remainders[i] = [-1, 1]
            end
          end
          #puts " expanded: #{remainders}"

          changes = 0
          remainders.each_with_index do |r, i|
            next unless r.is_a?(Array)
            changes += 1
    
            c, n = r
            remainders[i+1] = 0 if remainders[i+1].nil?
            if remainders[i+1].is_a?(Array)
              remainders[i+1][0] += n
            else
              remainders[i+1] += n
            end
            remainders[i] = c
          end
          #puts " flatten_pass: #{remainders}"
        end

        res = remainders.map do |r|
          if r == -2
            "="
          elsif r == -1
            "-"
          else
            r.to_s
          end
        end

        res.reverse.join("")
      end

      def s_to_i(string)
        digits = string.chars.map do |ch|
          if ch == "-"
            -1
          elsif ch == "="
            -2
          else
            Integer(ch)
          end
        end

        n = digits.size-1
        integer = 0
        digits.each_with_index do |d, i|
          pos = n - i
          integer += d*(5**pos)
        end

        integer
      end
    end

    def to_i
      @integer
    end

    def to_s
      @value
    end

  end

  class FullHotAir
  
    attr_reader :levels

    def initialize
      @levels = []
    end

    def add_balloon_level(string)
      @levels << Snafu.new(string)
    end

    def self.from(data)
      data = File.read(data) if File.exist?(data)

      o = FullHotAir.new
      data.each_line do |line|
        l = line.strip
        o.add_balloon_level(l)
      end

      o
    end

    def sum
      @levels.inject(0) { |sum, level| sum + level.to_i }
    end
  end

  class Day25
    def self.run(argv)
      o = FullHotAir.from(argv[0])
     
      sum = o.sum
      puts "Part 1: #{o.sum} / #{Snafu.i_to_s(sum)}"
    end
  end
end
