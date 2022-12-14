
# A = rock      A > C, B > A, C > B
# B = paper
# C = scissors
module Advent2022
  class RockPaperScissors

    def initialize(rules)
      @rules = rules
      @total = 0
    end

    def self.from_file(name, rules)
      game = RockPaperScissors.new(rules)

      File.readlines(name).each do |line|
        game.play_line(line)
      end

      game
    end

    def play_line(line)
      value = line.strip
      opponent, me = value.split(/ /)

      @total += @rules.score(me, opponent)
    end  

    def total
      @total
    end

    class Rules1
      def initialize(mappings)
        @mappings = mappings
      end

      def score(me, opponent)
        mine = @mappings[me]

        total = mine.ord - 'A'.ord + 1

        return total + 3 if mine == opponent
        return total + 6 if mine == 'A' && opponent == 'C'
        return total + 6 if mine == 'B' && opponent == 'A'
        return total + 6 if mine == 'C' && opponent == 'B'

        total
      end
    end

    class Rules2
      # Y = draw, X = loose, Z = win
      def score(me, opponent)
        if me == 'Y'
          mine = draw_to(opponent)
          total = 3
        elsif me == 'X'
          mine = loose_to(opponent)
          total = 0
        else
          mine = beat(opponent)
          total = 6
        end

        total += mine.ord - 'A'.ord + 1
      end

      def draw_to(value)
        value
      end

      def loose_to(value)
        return 'C' if value == 'A'
        return 'A' if value == 'B'
        'B'
      end

      def beat(value)
        return 'B' if value == 'A'
        return 'C' if value == 'B'
        'A'
      end
    end
  end

  class Day02
    def self.run(argv)
      rules = RockPaperScissors::Rules1.new({'X' => 'A', 'Y' => 'B', 'Z' => 'C'})
      game = RockPaperScissors.from_file(argv[0], rules)

      puts game.total

      rules = RockPaperScissors::Rules2.new
      game = RockPaperScissors.from_file(argv[0], rules)

      puts game.total
    end
  end

end

