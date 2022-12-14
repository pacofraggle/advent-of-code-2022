require 'minitest/autorun'
require_relative 'day08'

module Advent2022
  class ForestTest < Minitest::Test

    def test_sample
      f = forest_sample

      (0..4).each do |i|
        assert_equal true, f.visible?(0, i)
        assert_equal true, f.visible?(i, 0)
        assert_equal true, f.visible?(4, i)
        assert_equal true, f.visible?(i, 4)
      end
       
      assert_equal true, f.visible?(1, 1)
      assert_equal true, f.visible?(1, 2)
      assert_equal false, f.visible?(1, 3)

      assert_equal true, f.visible?(2, 1)
      assert_equal false, f.visible?(2, 2)
      assert_equal true, f.visible?(2, 3)

      assert_equal false, f.visible?(3, 1)
      assert_equal true, f.visible?(3, 2)
      assert_equal false, f.visible?(3, 3)


      assert_equal 21, f.visible
    end

    def test_scenic_score
      f = forest_sample

      (0..4).each do |i|
        assert_equal 0, f.scenic_score(0, i)
        assert_equal 0, f.scenic_score(i, 0)
        assert_equal 0, f.scenic_score(4, i)
        assert_equal 0, f.scenic_score(i, 4)
      end
 
      assert_equal 4, f.scenic_score(1, 2)
      assert_equal 8, f.scenic_score(3, 2)
    end

    def forest_sample
      sample = <<EOS
30373
25512
65332
33549
35390
EOS
      o = Forest.new

      sample.each_line do |line|
        o.add_trees_line(line)
      end

      o
    end
  end
end
