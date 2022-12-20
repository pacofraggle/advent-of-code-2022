require 'minitest/autorun'
require_relative 'day20'

module Advent2022
  class GrovePositioningSystemTest < Minitest::Test

    def test_move_right
      gps = GrovePositioningSystem.new
      [4, 5, 6, 1, 7, 8, 9].each { |i| gps.add_number(i) }

      gps.move(3)
      assert_equal [4, 5, 6, 7, 1, 8, 9], gps.sequence
    end

    def test_move_right
      gps = GrovePositioningSystem.new
      [4, -2, 5, 6, 7, 8, 9].each { |i| gps.add_number(i) }

      gps.move(1)
      assert_equal [4, 5, 6, 7, 8, -2, 9], gps.sequence
    end


    def test_from
      gps = GrovePositioningSystem.from(sample)

      assert_equal [1, 2, -3, 3, -2, 0, 4], gps.sequence
    end

    def test_pivot
      gps = GrovePositioningSystem.from(sample)

      moved = gps.pivot
      assert_equal 1, moved
      assert_equal [2, 1, -3, 3, -2, 0, 4], gps.sequence

      moved = gps.pivot
      assert_equal 2, moved
      assert_equal [1, -3, 2, 3, -2, 0, 4], gps.sequence

      moved = gps.pivot
      assert_equal -3, moved
      assert_equal [1, 2, 3, -2, -3, 0, 4], gps.sequence

      moved = gps.pivot
      assert_equal 3, moved
      assert_equal [1, 2, -2, -3, 0, 3, 4], gps.sequence

      moved = gps.pivot
      assert_equal -2, moved
      assert_equal [1, 2, -3, 0, 3, 4, -2], gps.sequence

      moved = gps.pivot
      assert_equal 0, moved
      assert_equal [1, 2, -3, 0, 3, 4, -2], gps.sequence

      moved = gps.pivot
      assert_equal 4, moved
      assert_equal [1, 2, -3, 4, 0, 3, -2], gps.sequence
    end

    def test_mix
      gps = GrovePositioningSystem.from(sample)

      gps.mix

      assert_equal [1, 2, -3, 4, 0, 3, -2], gps.sequence
    end

    def test_find
      gps = GrovePositioningSystem.from(sample)

      pos = gps.find(0)
      assert_equal 5, pos
    end

    def test_dont_find
      gps = GrovePositioningSystem.from(sample)

      pos = gps.find(23)
      assert pos.nil?
    end


    def test_grove_coords
      gps = GrovePositioningSystem.from(sample)
      gps.mix 
      coords = gps.grove_coords

      assert_equal [4, -3, 2], coords
    end

    def test_apply_key
      gps = GrovePositioningSystem.from(sample)
      gps.apply_key

      assert_equal [811589153, 1623178306, -2434767459, 2434767459, -1623178306, 0, 3246356612], gps.sequence
    end

    def test_rounds
      gps = GrovePositioningSystem.from(sample)
      gps.set_unshift
      gps.apply_key

      gps.mix
      assert_equal [0, -2434767459, 3246356612, -1623178306, 2434767459, 1623178306, 811589153], gps.sequence

      gps.mix
      assert_equal [0, 2434767459, 1623178306, 3246356612, -2434767459, -1623178306, 811589153], gps.sequence

      gps.mix
      assert_equal [0, 811589153, 2434767459, 3246356612, 1623178306, -1623178306, -2434767459], gps.sequence

      gps.mix
      assert_equal [0, 1623178306, -2434767459, 811589153, 2434767459, 3246356612, -1623178306], gps.sequence

      gps.mix
      assert_equal [0, 811589153, -1623178306, 1623178306, -2434767459, 3246356612, 2434767459], gps.sequence

      gps.mix
      assert_equal [0, 811589153, -1623178306, 3246356612, -2434767459, 1623178306, 2434767459], gps.sequence

      gps.mix
      assert_equal [0, -2434767459, 2434767459, 1623178306, -1623178306, 811589153, 3246356612], gps.sequence

      gps.mix
      assert_equal [0, 1623178306, 3246356612, 811589153, -2434767459, 2434767459, -1623178306], gps.sequence

      gps.mix
      assert_equal [0, 811589153, 1623178306, -2434767459, 3246356612, 2434767459, -1623178306], gps.sequence

      gps.mix
      assert_equal [0, -2434767459, 1623178306, 3246356612, -1623178306, 2434767459, 811589153], gps.sequence
    end


    def sample
      sample = <<EOS
1
2
-3
3
-2
0
4
EOS

      sample
    end

  end
end
