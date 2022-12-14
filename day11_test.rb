require 'minitest/autorun'
require_relative 'day11'

module Advent2022
  class MonkeyBusinessTest < Minitest::Test

    def test_from_setup
      mb = MonkeyBusiness.from_setup(sample_setup)

      assert_equal 0, mb.monkeys[0].id
      assert_equal [79, 98], mb.monkeys[0].items
      assert_equal 2, mb.monkeys[0].true
      assert_equal 3, mb.monkeys[0].false

      assert_equal 1, mb.monkeys[1].id
      assert_equal [54, 65, 75, 74], mb.monkeys[1].items
      assert_equal 2, mb.monkeys[1].true
      assert_equal 0, mb.monkeys[1].false

      assert_equal 2, mb.monkeys[2].id
      assert_equal [79, 60, 97], mb.monkeys[2].items
      assert_equal 1, mb.monkeys[2].true
      assert_equal 3, mb.monkeys[2].false

      assert_equal 3, mb.monkeys[3].id
      assert_equal [74], mb.monkeys[3].items
      assert_equal 0, mb.monkeys[3].true
      assert_equal 1, mb.monkeys[3].false
    end

    def test_round
      mb = MonkeyBusiness.from_setup(sample_setup)

      mb.round
      items = mb.monkey_items

      assert_equal [20, 23, 27, 26], items[0]
      assert_equal [2080, 25, 167, 207, 401, 1046], items[1]
      assert_equal [], items[2]
      assert_equal [], items[3]

      mb.round
      items = mb.monkey_items

      assert_equal [695, 10, 71, 135, 350], items[0]
      assert_equal [43, 49, 58, 55, 362], items[1]
      assert_equal [], items[2]
      assert_equal [], items[3]

      mb.round
      items = mb.monkey_items

      assert_equal [16, 18, 21, 20, 122], items[0]
      assert_equal [1468, 22, 150, 286, 739], items[1]
      assert_equal [], items[2]
      assert_equal [], items[3]

      mb.round
      items = mb.monkey_items

      assert_equal [491, 9, 52, 97, 248, 34], items[0]
      assert_equal [39, 45, 43, 258], items[1]
      assert_equal [], items[2]
      assert_equal [], items[3]
    end

    def test_20_rounds
      mb = MonkeyBusiness.from_setup(sample_setup)

      1.upto(20) { |_| mb.round }
      items = mb.monkey_items

      assert_equal [10, 12, 14, 26, 34], items[0]
      assert_equal [245, 93, 53, 199, 115], items[1]
      assert_equal [], items[2]
      assert_equal [], items[3]

      assert_equal [101, 95, 7, 105], mb.monkey_inspections
      assert_equal 10605, mb.value
    end

    def test_super_20_rounds
      mb = MonkeyBusiness.from_setup(sample_setup, true)

      mb.round
      assert_equal [2, 4, 3, 6], mb.monkey_inspections

      2.upto(20) { |_| mb.round }

      assert_equal [99, 97, 8, 103], mb.monkey_inspections
    end

    def test_super_1000_rounds
      mb = MonkeyBusiness.from_setup(sample_setup, true)
      mb.rounds(1000)

      assert_equal [5204, 4792, 199, 5192], mb.monkey_inspections
    end

    def test_super_more_rounds
      mb = MonkeyBusiness.from_setup(sample_setup, true)

      mb.rounds(2000)
      assert_equal [10419, 9577, 392, 10391], mb.monkey_inspections

      mb.rounds(1000)
      assert_equal [15638, 14358, 587, 15593], mb.monkey_inspections

      mb.rounds(1000)
      assert_equal [20858, 19138, 780, 20797], mb.monkey_inspections

      mb.rounds(1000)
      assert_equal [26075, 23921, 974, 26000], mb.monkey_inspections

      mb.rounds(1000)
      assert_equal [31294, 28702, 1165, 31204], mb.monkey_inspections

      mb.rounds(1000)
      assert_equal [36508, 33488, 1360, 36400], mb.monkey_inspections

      mb.rounds(1000)
      assert_equal [41728, 38268, 1553, 41606], mb.monkey_inspections

      mb.rounds(1000)
      assert_equal [46945, 43051, 1746, 46807], mb.monkey_inspections
    end


    def test_super_10000_rounds
      mb = MonkeyBusiness.from_setup(sample_setup, true)
      mb.rounds(10000)

      assert_equal [52166, 47830, 1938, 52013], mb.monkey_inspections
    end


    def xtest_roundx
      mb = MonkeyBusiness.from_setup(sample_setup)

      puts "Round 0: #{mb.monkey_inspections}"
      mb.monkey_items.each { |m| puts "  "+m.to_s }
      1.upto(20) do |n|
        mb.round
        puts "Round #{n}: #{mb.monkey_inspections}"
        mb.monkey_items.each { |m| puts "  "+m.to_s }
      end
    end

    def sample_setup
      sample = <<EOS
Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

Monkey 1:
  Starting items: 54, 65, 75, 74
  Operation: new = old + 6
  Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

Monkey 2:
  Starting items: 79, 60, 97
  Operation: new = old * old
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

Monkey 3:
  Starting items: 74
  Operation: new = old + 3
  Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1
EOS

      sample
    end

  end
end
