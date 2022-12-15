require 'minitest/autorun'
require_relative 'day15'

module Advent2022
  class BeaconExclusionZoneTest < Minitest::Test

    def test_from
      z = BeaconExclusionZone.from(sample)

      s = z.sensors.first
      assert_equal Point.new(2, 18), s.sensor
      assert_equal Point.new(-2, 15), s.beacon

      s = z.sensors.last
      assert_equal Point.new(20, 1), s.sensor
      assert_equal Point.new(15, 3), s.beacon
    end

    def test_check_from  
      z = BeaconExclusionZone.from(sample)

      assert_equal 26, z.check_row(10)
    end

    def sample
      sample = <<EOS
Sensor at x=2, y=18: closest beacon is at x=-2, y=15
Sensor at x=9, y=16: closest beacon is at x=10, y=16
Sensor at x=13, y=2: closest beacon is at x=15, y=3
Sensor at x=12, y=14: closest beacon is at x=10, y=16
Sensor at x=10, y=20: closest beacon is at x=10, y=16
Sensor at x=14, y=17: closest beacon is at x=10, y=16
Sensor at x=8, y=7: closest beacon is at x=2, y=10
Sensor at x=2, y=0: closest beacon is at x=2, y=10
Sensor at x=0, y=11: closest beacon is at x=2, y=10
Sensor at x=20, y=14: closest beacon is at x=25, y=17
Sensor at x=17, y=20: closest beacon is at x=21, y=22
Sensor at x=16, y=7: closest beacon is at x=15, y=3
Sensor at x=14, y=3: closest beacon is at x=15, y=3
Sensor at x=20, y=1: closest beacon is at x=15, y=3
EOS

      sample
    end

  end
end
