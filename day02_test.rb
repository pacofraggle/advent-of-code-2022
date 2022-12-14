require 'minitest/autorun'
require_relative 'day02'

module Advent2022
  class RockPaperScissorsTest < Minitest::Test

    def test_score_moves_rules1
      assert_equal 4, rules1.score('X', 'A')
      assert_equal 1, rules1.score('X', 'B')
      assert_equal 7, rules1.score('X', 'C')

      assert_equal 5, rules1.score('Y', 'B')
      assert_equal 8, rules1.score('Y', 'A')
      assert_equal 2, rules1.score('Y', 'C')

      assert_equal 6, rules1.score('Z', 'C')
      assert_equal 3, rules1.score('Z', 'A')
      assert_equal 9, rules1.score('Z', 'B')
    end

    def test_play_line_rules1
      assert_equal 15, rock_paper_scissors_sample(rules1).total
    end

    def test_score_moves_rules2
      assert_equal 4, rules2.score('Y', 'A')
      assert_equal 5, rules2.score('Y', 'B')
      assert_equal 6, rules2.score('Y', 'C')

      assert_equal 3, rules2.score('X', 'A')
      assert_equal 1, rules2.score('X', 'B')
      assert_equal 2, rules2.score('X', 'C')

      assert_equal 8, rules2.score('Z', 'A')
      assert_equal 9, rules2.score('Z', 'B')
      assert_equal 7, rules2.score('Z', 'C')
    end

    def test_play_line_rules2
      assert_equal 12, rock_paper_scissors_sample(rules2).total
    end



    def rock_paper_scissors_sample(rules)
      sample = <<EOS
A Y
B X
C Z
EOS
      c = RockPaperScissors.new(rules)

      sample.each_line do |line|
        c.play_line(line)
      end

      c
    end

    def rules1
      @rules1 ||= RockPaperScissors::Rules1.new({'X' => 'A', 'Y' => 'B', 'Z' => 'C'})
    end

    def rules2
      @rules2 ||= RockPaperScissors::Rules2.new
    end
  end
end
