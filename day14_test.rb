require 'minitest/autorun'
require_relative 'day14'

module Advent2022
  class RegolithReservoirTest < Minitest::Test

    def test_new_cave
      rr = RegolithReservoir.from(sample)
      expected = <<EOS
......+...
..........
..........
..........
....#...##
....#...#.
..###...#.
........#.
........#.
#########.
EOS

      assert_equal expected.strip, rr.cave.to_s
    end

    def test_sand_fall
      rr = RegolithReservoir.from(sample)
      expected = <<EOS
......+...
..........
..........
..........
....#...##
....#...#.
..###...#.
........#.
......o.#.
#########.
EOS
      rr.cave.sand
      assert_equal expected.strip, rr.cave.to_s

      expected = <<EOS
......+...
..........
..........
..........
....#...##
....#...#.
..###...#.
........#.
.....oo.#.
#########.
EOS
      rr.cave.sand
      assert_equal expected.strip, rr.cave.to_s

      expected = <<EOS
......+...
..........
..........
..........
....#...##
....#...#.
..###...#.
........#.
.....ooo#.
#########.
EOS
      rr.cave.sand
      assert_equal expected.strip, rr.cave.to_s
      
      expected = <<EOS
......+...
..........
..........
..........
....#...##
....#...#.
..###...#.
......o.#.
.....ooo#.
#########.
EOS
      rr.cave.sand
      assert_equal expected.strip, rr.cave.to_s

      expected = <<EOS
......+...
..........
..........
..........
....#...##
....#...#.
..###...#.
......o.#.
....oooo#.
#########.
EOS
      rr.cave.sand
      assert_equal expected.strip, rr.cave.to_s
    end

    def test_sand_fall_many
      rr = RegolithReservoir.from(sample)

      expected = <<EOS
......+...
..........
......o...
.....ooo..
....#ooo##
....#ooo#.
..###ooo#.
....oooo#.
...ooooo#.
#########.
EOS
      rr.cave.sand(22)
      assert_equal expected.strip, rr.cave.to_s

      expected = <<EOS
......+...
..........
......o...
.....ooo..
....#ooo##
...o#ooo#.
..###ooo#.
....oooo#.
.o.ooooo#.
#########.
EOS
      rr.cave.sand(2)
      assert_equal expected.strip, rr.cave.to_s
    end

    def test_sand_fall_spill
      rr = RegolithReservoir.from(sample)

      units = rr.spill
      assert_equal 24, units
      assert_equal 24, rr.cave.sand_amount
    end

    def test_new_cave_with_floor
      rr = RegolithReservoir.from(sample, true)
      expected = <<EOS
......+...
..........
..........
..........
....#...##
....#...#.
..###...#.
........#.
........#.
#########.
..........
##########
EOS

      assert_equal expected.strip, rr.cave.to_s
      units = rr.cave.overflow_sand
      expected = <<EOS
..........o..........
.........ooo.........
........ooooo........
.......ooooooo.......
......oo#ooo##o......
.....ooo#ooo#ooo.....
....oo###ooo#oooo....
...oooo.oooo#ooooo...
..oooooooooo#oooooo..
.ooo#########ooooooo.
ooooo.......ooooooooo
#####################
EOS
      assert_equal 93, units
      assert_equal expected.strip, rr.cave.to_s
    end

    def sample
      sample = <<EOS
498,4 -> 498,6 -> 496,6
503,4 -> 502,4 -> 502,9 -> 494,9
EOS

      sample
    end
  end
end
