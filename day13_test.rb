require 'minitest/autorun'
require_relative 'day13'

module Advent2022
  class DistressSignalTest < Minitest::Test

    def test_packet_from_string
      p = Packet.from_string("[3, [4, 5]]")

      assert_equal [3, [4, 5]], p.data
    end

    def test_from
      ds = DistressSignal.from(sample)

      assert_equal 8, ds.pairs.size
      assert_equal [], ds.pair(6).left.data
      assert_equal [1,[2,[3,[4,[5,6,0]]]],8,9], ds.pair(8).right.data
    end

    def test_pair
      ds = DistressSignal.from(sample)

      assert_equal [[1],[2,3,4]], ds.pair(2).left.data
      assert_equal [[1],4], ds.pair(2).right.data
      assert_equal [[[]]], ds.pair(7).left.data
      assert_equal [[]], ds.pair(7).right.data
    end

    def test_compare_pair
      ds = DistressSignal.from(sample)

      assert_equal Packet::RIGHT, ds.pair(1).compare
      assert_equal Packet::RIGHT, ds.pair(2).compare
      assert_equal Packet::WRONG, ds.pair(3).compare
      assert_equal Packet::RIGHT, ds.pair(4).compare
      assert_equal Packet::WRONG, ds.pair(5).compare
      assert_equal Packet::RIGHT, ds.pair(6).compare
      assert_equal Packet::WRONG, ds.pair(7).compare
      assert_equal Packet::WRONG, ds.pair(8).compare
    end

    def test_comparison_aggregates
      ds = DistressSignal.from(sample)

      assert_equal [-1, -1, 1, -1, 1, -1, 1, 1], ds.compare_pairs
      assert_equal [1, 2, 4, 6], ds.right_pairs
      assert_equal 13, ds.sum_of_right_pairs
    end

    def test_ordering
      ds = DistressSignal.from(sample)
      a = Packet.new([[2]])
      b = Packet.new([[6]])
      ds.add_packet(a)
      ds.add_packet(b)

      ds.packets.sort!
      a_pos = ds.find_index_of(a)
      b_pos = ds.find_index_of(b)

      assert_equal 10, a_pos
      assert_equal 14, b_pos
      assert_equal 140, ds.decoder(a, b)
    end

    def sample
      sample = <<EOS
[1,1,3,1,1]
[1,1,5,1,1]

[[1],[2,3,4]]
[[1],4]

[9]
[[8,7,6]]

[[4,4],4,4]
[[4,4],4,4,4]

[7,7,7,7]
[7,7,7]

[]
[3]

[[[]]]
[[]]

[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]
EOS

      sample
    end

  end
end
