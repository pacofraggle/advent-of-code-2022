require 'minitest/autorun'
require_relative 'day06'

module Advent2022
  class TuningTest < Minitest::Test

    def test_find_marker
      assert_equal 5, Tuning.find_marker("bvwbjplbgvbhsrlpgdmjqwftvncz")
      assert_equal 6, Tuning.find_marker("nppdvjthqldpwncqszvftbrmjlhg")
      assert_equal 10, Tuning.find_marker("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg")
      assert_equal 11, Tuning.find_marker("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw")
    end

    def test_find_marker_14
      assert_equal 19, Tuning.find_marker("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 14)
      assert_equal 23, Tuning.find_marker("bvwbjplbgvbhsrlpgdmjqwftvncz", 14)
      assert_equal 23, Tuning.find_marker("nppdvjthqldpwncqszvftbrmjlhg", 14)
      assert_equal 29, Tuning.find_marker("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 14)
      assert_equal 26, Tuning.find_marker("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 14)
    end
  end
end
