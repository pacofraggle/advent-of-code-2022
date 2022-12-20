require 'minitest/autorun'
require_relative 'day20'

module Advent2022
  class GrovePositioningSystemTest < Minitest::Test

    def test_linked_list
      ll = LinkedList.new
      [1, 2, 3].each { |i| ll.append(i) }

      assert_equal ll.tail, ll.head.prev
      assert_equal ll.head, ll.tail.next

      center = ll.head.next
      assert_equal 2, center.value
      assert center.prev == ll.head
      assert center.next == ll.tail

      ll.move_node_before(center, ll.head)
      assert_equal [1, 3, 2], ll.to_a

      center = ll.head.next
      assert_equal 3, center.value
      ll.move_node_after(center, ll.tail)
      assert_equal [3, 1, 2], ll.to_a
    end

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
      assert_equal 2, gps.list.head.value
      assert_equal 4, gps.list.tail.value

      moved = gps.pivot
      assert_equal 2, moved
      assert_equal [1, -3, 2, 3, -2, 0, 4], gps.sequence
      assert_equal 1, gps.list.head.value
      assert_equal 4, gps.list.tail.value

      moved = gps.pivot
      assert_equal -3, moved
      assert_equal [1, 2, 3, -2, -3, 0, 4], gps.sequence
      assert_equal 1, gps.list.head.value
      assert_equal 4, gps.list.tail.value

      moved = gps.pivot
      assert_equal 3, moved
      assert_equal [1, 2, -2, -3, 0, 3, 4], gps.sequence
      assert_equal 1, gps.list.head.value
      assert_equal 4, gps.list.tail.value

      moved = gps.pivot
      assert_equal -2, moved
      assert_equal [1, 2, -3, 0, 3, 4, -2], gps.sequence
      assert_equal 1, gps.list.head.value
      assert_equal -2, gps.list.tail.value

      moved = gps.pivot
      assert_equal 0, moved
      assert_equal [1, 2, -3, 0, 3, 4, -2], gps.sequence
      assert_equal 1, gps.list.head.value
      assert_equal -2, gps.list.tail.value

      moved = gps.pivot
      assert_equal 4, moved
      assert_equal [1, 2, -3, 4, 0, 3, -2], gps.sequence
      assert_equal 1, gps.list.head.value
      assert_equal -2, gps.list.tail.value
    end

    def test_mix
      gps = GrovePositioningSystem.from(sample)

      gps.mix

      assert_equal [1, 2, -3, 4, 0, 3, -2], gps.sequence
    end

    def test_find
      gps = GrovePositioningSystem.from(sample)

      node = gps.find(0)
      assert !node.nil?
      assert_equal -2, node.prev.value     
      assert_equal 4, node.next.value     
    end

    def test_dont_find
      gps = GrovePositioningSystem.from(sample)

      node = gps.find(23)
      assert node.nil?
    end


    def test_traverse
      gps = GrovePositioningSystem.from(sample)
    
      gps.mix

      node0 = gps.find(0)
      assert_equal 4, node0.prev.value     
      assert_equal 3, node0.next.value     

      first = gps.traverse(1000, node0)
      assert_equal 4, first.value

      second = gps.traverse(2000, node0)
      assert_equal -3, second.value

      third = gps.traverse(3000, node0)
      assert_equal 2, third.value

      assert_equal second.value, gps.traverse(1000, first).value
      assert_equal third.value, gps.traverse(1000, second).value
    end

    def test_grove_coords
      gps = GrovePositioningSystem.from(sample)
    
      coords = gps.grove_coords
      assert_equal [4, -3, 2], coords
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
