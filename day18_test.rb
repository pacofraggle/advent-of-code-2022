require 'minitest/autorun'
require 'pry'
require_relative 'day18'

module Advent2022
  class BoilingBouldersTest < Minitest::Test

    def test_overlap
      c1 = Cube.new(1, 1, 1)
      c2 = Cube.new(2, 1, 1)
     
      assert true, c1.overlap?(c2)
      assert true, c2.overlap?(c1)
    end

    def test_surface_area
      bb = BoilingBoulders.new
      bb.add_cube(1, 1, 1)
      bb.add_cube(2, 1, 1)

      assert_equal 10, bb.surface_area
    end

    def test_sample_surface_area
      bb = BoilingBoulders.from(sample)

      assert_equal 64, bb.surface_area
    end

    def test_filled_areas
      bb = BoilingBoulders.new
      bb.add_cube(1, 1, 1) 
      bb.add_cube(3, 1, 1) 
      bb.add_cube(2, 1, 0) 
      bb.add_cube(2, 1, 2) 

      bb.add_cube(2, 0, 1) 
      bb.add_cube(2, 2, 1) 

      assert_equal 36, bb.surface_area

      bb.add_cube(2, 1, 1)
      assert_equal 30, bb.surface_area
    end

    def test_bigger_filled_areas
      bb = BoilingBoulders.from(sample_hole)

      assert_equal 10*4 + 2*4*4, bb.surface_area

      bb.add_cube(2, 1, 1)
      bb.add_cube(3, 1, 1)
      bb.add_cube(2, 1, 2)
      bb.add_cube(3, 1, 2)

      assert_equal 8*4 + 2*3*4, bb.surface_area
    
    end

    def test_sample_exterior_surface_area
      bb = BoilingBoulders.from(sample)

      assert_equal 58, bb.exterior_surface_area
    end


    def sample
      sample = <<EOS
2,2,2
1,2,2
3,2,2
2,1,2
2,3,2
2,2,1
2,2,3
2,2,4
2,2,6
1,2,5
3,2,5
2,1,5
2,3,5
EOS

      sample
    end

    def sample_hole
      sample = <<EOS
1, 1, 1
1, 1, 2
2, 1, 0
3, 1, 0
4, 1, 1
4, 1, 2
2, 1, 3
3, 1, 3
2, 0, 1
3, 0, 1
2, 0, 2
3, 0, 2
2, 2, 1
3, 2, 1
2, 2, 2
3, 2, 2
EOS

      sample
    end


  end
end
