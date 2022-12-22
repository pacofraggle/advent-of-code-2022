require 'minitest/autorun'
require_relative 'day22'

module Advent2022
  class MonkeyMapTest < Minitest::Test

    def test_from
      mm = MonkeyMap.from(sample)
     
      assert_equal "10R5L5R10L4R5L5", mm.path.description
      assert_equal true, mm.map.closed
    end

    def test_starting_point
      map = MonkeyMap.from(sample).map
     
      assert_equal Position.new(1, 9, '.'), map.starting_point
    end

    def test_up_of
      map = MonkeyMap.from(sample).map
     
      assert_equal '.', map.cell(5, 3)
      assert_equal Position.new(8, 3, '.'), map.up_of(5, 3)[0]
      assert_equal Position.new(7, 3, '#'), map.up_of(8, 3)[0]
      assert_equal Position.new(12, 15, '#'), map.up_of(9, 15)[0]
      assert_equal Position.new(12, 11, '.'), map.up_of(1, 11)[0]
    end

    def test_down_of
      map = MonkeyMap.from(sample).map
     
      assert_equal Position.new(2, 10, '#'), map.down_of(1, 10)[0]
      assert_equal Position.new(5, 4, '#'), map.down_of(8, 4)[0]
      assert_equal Position.new(1, 9, '.'), map.down_of(12, 9)[0]
      assert_equal Position.new(9, 13, '.'), map.down_of(12, 13)[0]
    end

    def test_right_of
      map = MonkeyMap.from(sample).map
     
      assert_equal Position.new(2, 10, '#'), map.right_of(2, 9)[0]
      assert_equal Position.new(3, 9, '#'), map.right_of(3, 12)[0]
      assert_equal Position.new(6, 1, '.'), map.right_of(6, 12)[0]
      assert_equal Position.new(12, 9, '.'), map.right_of(12, 16)[0]
    end

    def test_left_of
      map = MonkeyMap.from(sample).map
     
      assert_equal Position.new(5, 3, '.'), map.left_of(5, 4)[0]
      assert_equal Position.new(1, 12, '#'), map.left_of(1, 9)[0]
      assert_equal Position.new(12, 16, '.'), map.left_of(12, 9)[0]
      assert_equal Position.new(5, 12, '#'), map.left_of(5, 1)[0]
    end

    def test_path
      p = Path.new("10R5L5R10L4R5L5")

      steps = p.steps

      assert_equal 13, steps.size
    end

    def test_route
      mm = MonkeyMap.from(sample)

      r = Route.new(mm.map, mm.path)

      dest, dir = r.follow

      assert_equal 6, dest.row
      assert_equal 8, dest.col
      assert_equal Path::RIGHT, dir
    end

    def test_password
      mm = MonkeyMap.from(sample)

      assert_equal 6032, mm.password
    end

    def test_cubic_map
      mm = MonkeyMap.from(sample, 4)

      w = WarpSetup.new
      w.add(1, [6, 4, 3, 2], [-1, 1, 1, 1, -1, 2])
      w.add(2, [3, 5, 6, 1], [1, -1, 0, -1, 3, 3])
      w.add(3, [4, 5, 2, 1], [0, 2, -1, 0, 0, 0])
      w.add(4, [6, 5, 3, 1], [3, -1, 2, -1, 1, 1])
      w.add(5, [6, 2, 3, 4], [-1, 3, 3, 3, -1, 0])
      w.add(6, [1, 2, 5, 4], [0, 0, -1, 2, 2, -1])
      mm.map.set_warp(w)
      
      dest, dir = mm.follow

      assert_equal 5, dest.row
      assert_equal 7, dest.col
      assert_equal Path::UP, dir
    end

    def test_cubic_password
      mm = MonkeyMap.from(sample, 4)

      w = WarpSetup.new
      w.add(1, [6, 4, 3, 2], [-1, 1, 1, 1, -1, 2])
      w.add(2, [3, 5, 6, 1], [1, -1, 0, -1, 3, 3])
      w.add(3, [4, 5, 2, 1], [0, 2, -1, 0, 0, 0])
      w.add(4, [6, 5, 3, 1], [3, -1, 2, -1, 1, 1])
      w.add(5, [6, 2, 3, 4], [-1, 3, 3, 3, -1, 0])
      w.add(6, [1, 2, 5, 4], [0, 0, -1, 2, 2, -1])
      mm.map.set_warp(w)
 
      assert_equal 5031, mm.password
    end


    def sample
      sample = <<EOS
        ...#
        .#..
        #...
        ....
...#.......#
........#...
..#....#....
..........#.
        ...#....
        .....#..
        .#......
        ......#.

10R5L5R10L4R5L5
EOS

      sample
    end

  end
end
