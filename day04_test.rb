require 'minitest/autorun'
require_relative 'day04'

module Advent2022
  class CleaningAssignmentsTest < Minitest::Test

    def test_pair_a_overlaps_b
      p = CleaningAssignments::Pair.new(2, 8, 3, 7)

      assert p.covers?
    end

    def test_pair_a_overlapped_by_b
      p = CleaningAssignments::Pair.new(3, 7, 2, 8)

      assert p.covers?
    end

    def test_pairs_dont_overlap
      p = CleaningAssignments::Pair.new(3, 7, 5, 8)

      assert !p.covers?
    end

    def test_covers
      s = assignments_sample

      assert_equal 2, s.covers.count
    end

    def test_overlaps
      s = assignments_sample

      assert_equal 4, s.overlaps.count
    end

    def assignments_sample
      sample = <<EOS
2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8
EOS
      o = CleaningAssignments.new

      sample.each_line do |line|
        o.add_pair_line(line)
      end

      o
    end
  end
end
