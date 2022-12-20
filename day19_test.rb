require 'minitest/autorun'
require_relative 'day19'

module Advent2022
  class NotEnoughMineralsTest < Minitest::Test

    def test_read_blueprints
      nem = NotEnoughMinerals.from(sample)

      assert_equal 2, nem.blueprints.size

      first = nem.blueprints[1]
      assert_equal 1, first.id
      assert_equal 4, first.ore_robot.ore
      assert_equal 2, first.clay_robot.ore
      assert_equal 3, first.obsidian_robot.ore
      assert_equal 14, first.obsidian_robot.clay
      assert_equal 2, first.geode_robot.ore
      assert_equal 7, first.geode_robot.obsidian

      first = nem.blueprints[2]
      assert_equal 2, first.id
      assert_equal 2, first.ore_robot.ore
      assert_equal 3, first.clay_robot.ore
      assert_equal 3, first.obsidian_robot.ore
      assert_equal 8, first.obsidian_robot.clay
      assert_equal 3, first.geode_robot.ore
      assert_equal 12, first.geode_robot.obsidian
    end

    def test_collector
      nem = NotEnoughMinerals.from(sample)
      c = nem.collector(1)

      1.upto(24) do |_|
        c.execute
        puts "minute #{c.minute} ==================="
        puts "  Stock:  #{c.stock}"
        puts "  Robots: #{c.robots}"
      end
    end

    def sample
      sample = <<EOS
Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
EOS

      sample
    end

  end
end
