module Advent2022
  class Rucksacks

    class Item
      def initialize(letter)
        @letter = letter
      end

      def self.priorities(letters)
        total = 0
        letters.each do |m|
          total += Item.new(m).priority
        end

        total
      end

      def priority
        pos = @letter.downcase.ord - 'a'.ord + 1

        @letter == @letter.upcase ? pos + 26 : pos
      end

      def to_s
        @letter
      end
    end

    def initialize
      @rucksacks = []
    end

    def self.from_file(name)
      r  = Rucksacks.new

      File.readlines(name).each do |line|
        r.add_rucksack_line(line)
      end

      r
    end

    def add_rucksack_line(line)
      @rucksacks << line.strip
    end  

    def misplacements
      @rucksacks.map do |sack|
        Rucksacks.line_misplacements(sack)
      end.compact.flatten
    end

    def priorities
      Item.priorities(misplacements)
    end

    def group_badges
      @rucksacks.each_slice(3).to_a.map do |group|
        dups = Rucksacks.duplicates(group[0], group[1])
        Rucksacks.duplicates(dups, group[2]).chars
      end.flatten
    end

    def group_priorities
      Item.priorities(group_badges)
    end

    def self.compartments(line)
      [ line[0..(line.size/2 - 1)], line[(line.size/2)..-1] ] 
    end

    def self.line_misplacements(line)
      compartments = Rucksacks.compartments(line)
      dups = []
      compartments[0].each_char do |ch|
        dups << ch if compartments[1].include?(ch)
      end

      dups.uniq
    end

    def self.duplicates(a, b)
      a.chars.uniq.select do |ch|
        b.include?(ch) 
      end.join
    end
  end


  class Day03
    def self.run(argv)
      sacks = Rucksacks.from_file(argv[0])
      puts sacks.priorities
      puts sacks.group_priorities
    end
  end
end
