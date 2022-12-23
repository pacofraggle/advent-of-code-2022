require 'minitest/autorun'
require_relative 'day23'

module Advent2022
  class UnstableDiffusionTest < Minitest::Test

    def test_elf
      elf = Elf.new(1)


      assert_equal 1, elf.id
      assert_equal 0, elf.rule

      rules = elf.rules_a
      assert_equal 4, rules.size
      assert_equal :N, rules.first[0]
      assert_equal :E, rules.last[0]

      5.times { elf.move_rule }
      rules = elf.rules_a
      assert_equal 4, rules.size
      assert_equal :S, rules.first[0]
      assert_equal :N, rules.last[0]
    end

    def test_from
      ud = UnstableDiffusion.from(sample)

      assert_equal 5, ud.ground.elves.size
      assert_equal Location.new(1, 2), ud.ground.elves.keys.first
      assert_equal Location.new(4, 3), ud.ground.elves.keys.last
    end

    def test_rounds
      ud = UnstableDiffusion.from(sample)
      expected =<<EOS
##
..
#.
.#
#.
EOS
      ud.round
      assert_equal expected.strip, ud.ground.area

      expected =<<EOS
.##.
#...
...#
....
.#..
EOS
 
      ud.round
      assert_equal expected.strip, ud.ground.area

      expected =<<EOS
..#..
....#
#....
....#
.....
..#..
EOS

      ud.round
      assert_equal expected.strip, ud.ground.area

      ud.round
      assert_equal expected.strip, ud.ground.area

      5.times { ud.round } 
      assert_equal expected.strip, ud.ground.area
    end

    def test_rounds_larger
      ud = UnstableDiffusion.from(larger_sample)

      expected =<<EOS
......#.....
..........#.
.#.#..#.....
.....#......
..#.....#..#
#......##...
....##......
.#........#.
...#.#..#...
............
...#..#..#..
EOS

      ud.round(10)
      assert_equal expected.strip, ud.ground.area
      assert_equal 110, ud.empty_ground
    end


    def test_rounds_equilibrium
      ud = UnstableDiffusion.from(larger_sample)

      finished = ud.rounds
      assert_equal 20, finished
    end

    def sample
      sample = <<EOS
.....
..##.
..#..
.....
..##.
.....
EOS

      sample
    end

    def larger_sample
      sample = <<EOS
....#..
..###.#
#...#.#
.#...##
#.###..
##.#.##
.#..#..
EOS

      sample
    end

  end
end
