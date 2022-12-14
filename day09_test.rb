require 'minitest/autorun'
require_relative 'day09'

module Advent2022
  class ForestTest < Minitest::Test

    def test_move_right
      r = Rope.new

      r.move_head('R')

      assert_equal Position.new(1, 0), r.head
      assert_equal Position.new(0, 0), r.tail
      assert_equal 1, r.trace_count


      r.move_head('R')

      assert_equal Position.new(2, 0), r.head
      assert_equal Position.new(1, 0), r.tail
      assert_equal 2, r.trace_count
    end

    def test_move_left
      r = Rope.new

      r.move_head('L')

      assert_equal Position.new(-1, 0), r.head
      assert_equal Position.new(0, 0), r.tail
      assert_equal 1, r.trace_count


      r.move_head('L')

      assert_equal Position.new(-2, 0), r.head
      assert_equal Position.new(-1, 0), r.tail
      assert_equal 2, r.trace_count
    end

    def test_move_up
      r = Rope.new

      r.move_head('U')

      assert_equal Position.new(0, 1), r.head
      assert_equal Position.new(0, 0), r.tail
      assert_equal 1, r.trace_count


      r.move_head('U')

      assert_equal Position.new(0, 2), r.head
      assert_equal Position.new(0, 1), r.tail
      assert_equal 2, r.trace_count
    end

    def test_move_down
      r = Rope.new

      r.move_head('D')

      assert_equal Position.new(0, -1), r.head
      assert_equal Position.new(0, 0), r.tail
      assert_equal 1, r.trace_count


      r.move_head('D')

      assert_equal Position.new(0, -2), r.head
      assert_equal Position.new(0, -1), r.tail
      assert_equal 2, r.trace_count
    end

    def test_sample
      r = rope_sample

      assert_equal 13, r.trace_count
    end

    def test_sample10
      r = rope_sample(10)

      assert_equal 1, r.trace_count
    end

    def test_larger_sample
      r = rope_larger_sample

      assert_equal 36, r.trace_count
    end

    def rope_sample(knots=2)
      sample = <<EOS
R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2
EOS
      o = Rope.new(knots)

      sample.each_line do |line|
        o.head_move_line(line)
      end

      o
    end

    def rope_larger_sample
      sample = <<EOS
R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20
EOS
      o = Rope.new(10)

      sample.each_line do |line|
        o.head_move_line(line)
      end

      o
    end
  end
end
