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

    def test_can_build_robot
      nem = NotEnoughMinerals.from(sample)
      bp = nem.blueprints[1]

      assert_equal false, bp.can_build_robot?(type: :ore, stock: [3, 0, 0, 0])
      assert_equal true, bp.can_build_robot?(type: :ore, stock: [4, 0, 0, 0])

      assert_equal false, bp.can_build_robot?(type: :clay, stock: [1, 0, 0, 0])
      assert_equal true, bp.can_build_robot?(type: :clay, stock: [2, 0, 0, 0])

      assert_equal false, bp.can_build_robot?(type: :obsidian, stock: [4, 13, 0, 0])
      assert_equal true, bp.can_build_robot?(type: :obsidian, stock: [3, 14, 0, 0])

      assert_equal false, bp.can_build_robot?(type: :geode, stock: [3, 0, 6, 0])
      assert_equal true, bp.can_build_robot?(type: :geode, stock: [2, 0, 7, 0])
    end

    def test_can_build
      nem = NotEnoughMinerals.from(sample)
      bp = nem.blueprints[1]

      assert_equal [:ore, :clay, :obsidian, :geode], bp.can_build(stock: [4, 14, 7, 0])
      assert_equal [:clay, :obsidian, :geode], bp.can_build(stock: [3, 14, 7, 0])
      assert_equal [], bp.can_build(stock: [1, 14, 7, 0])
    end

    def test_find_max_24
      nem = NotEnoughMinerals.from(sample)
      assert_equal 9, nem.find_max(1, 24)
      assert_equal 12, nem.find_max(2, 24)
    end

    def test_find_max_32
      nem = NotEnoughMinerals.from(sample)

      assert_equal 56, nem.find_max(1, 32)
      assert_equal 62, nem.find_max(2, 32)
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
