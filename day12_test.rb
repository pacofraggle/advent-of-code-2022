require 'minitest/autorun'
require_relative 'day12'

module Advent2022
  class HillClimbingTest < Minitest::Test

    def test_read
      hc = HillClimbing.from_grid(sample_map)

      v = hc.graph.node(0, 0)
      e = hc.graph.node(0, 1)
      s = hc.graph.node(1, 0)

      assert v == hc.graph.initial
      assert_equal 0, v.height
      assert_equal 'S', v.value
      assert_equal 2, v.neighbours.size
      assert_equal s, v.neighbours.first
      assert_equal e, v.neighbours.last

      v = hc.graph.node(2, 4)
      n = hc.graph.node(1, 4)
      s = hc.graph.node(3, 4)
      e = hc.graph.node(2, 5)
      w = hc.graph.node(2, 3)

      assert hc.graph.destination == e
      assert_equal 25, v.height
      assert_equal 'z', v.value
      assert_equal 4, v.neighbours.size
      assert_equal n, v.neighbours[0]
      assert_equal s, v.neighbours[1]
      assert_equal w, v.neighbours[2]
      assert_equal e, v.neighbours[3]
    end

    def test_dijkstra
      hc = HillClimbing.from_grid(sample_map)

      assert_equal 31, hc.graph.shortest_path
      assert_equal 31, hc.shortest_path
    end

    def test_reverse
      hc = HillClimbing.from_grid_reverse(sample_map)

      assert_equal 31, hc.shortest_path
    end

    def test_shortest_to
      hc = HillClimbing.from_grid_reverse(sample_map)
      
      result = hc.shortest_path_to_letter('z')

      assert_equal 29, result
    end

    def sample_map
      sample = <<EOS
Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
EOS

      sample
    end

  end
end
