require 'minitest/autorun'
require_relative 'day03'

module Advent2022
  class RucksacksTest < Minitest::Test

    def test_rucksack_item
      item1 = Rucksacks::Item.new('a')
      item2 = Rucksacks::Item.new('A')

      assert_equal 1, item1.priority
      assert_equal 27, item2.priority
    end

    def test_compartments
      line = "vJrwpWtwJgWrhcsFMMfFFhFp"

      compartments = Rucksacks.compartments(line)
      assert_equal 2, compartments.size
      assert_equal "vJrwpWtwJgWr", compartments[0]
      assert_equal "hcsFMMfFFhFp", compartments[1]
    end

    def test_line_misplacements
      line = "vJrwpWtwJgWrhcsFMMfFFhFp"

      misplacements = Rucksacks.line_misplacements(line)

      assert_equal ['p'], misplacements    
    end

    def test_duplicates
      assert_equal 'cd', Rucksacks.duplicates('bcda', 'ddc')
    end

    def test_check_rucksacks
      r = rucksack_sample

      assert_equal ['p', 'L', 'P', 'v', 't', 's'], r.misplacements
      assert_equal 157, r.priorities
    end

    def test_group_badges
      r = rucksack_sample

      assert_equal ['r', 'Z'], r.group_badges
      assert_equal 70, r.group_priorities
    end

    def rucksack_sample
      sample = <<EOS
vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw
EOS
      o = Rucksacks.new

      sample.each_line do |line|
        o.add_rucksack_line(line)
      end

      o
    end
  end
end
