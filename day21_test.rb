require 'minitest/autorun'
require_relative 'day21'

module Advent2022
  class MonkeyMathTest < Minitest::Test

    def test_from
      mm = MonkeyMath.from(sample)

      assert_equal 15, mm.monkeys.size
    end

    def test_value_direct
      mm = MonkeyMath.from(sample)

      assert_equal 5, mm.value("dbpl")
    end

    def test_value_indirect1
      mm = MonkeyMath.from(sample)

      assert_equal 30, mm.value("drzm")
    end

    def test_value_indirect_several
      mm = MonkeyMath.from(sample)

      assert_equal 152, mm.value("root")
    end

    def test_human_yell
      mm = MonkeyMath.from(sample)

      assert_equal 301, mm.human_yell
    end

    def sample
      sample = <<EOS
root: pppw + sjmn
dbpl: 5
cczh: sllz + lgvd
zczc: 2
ptdq: humn - dvpt
dvpt: 3
lfqf: 4
humn: 5
ljgn: 2
sjmn: drzm * dbpl
sllz: 4
pppw: cczh / lfqf
lgvd: ljgn * ptdq
drzm: hmdt - zczc
hmdt: 32
EOS

      sample
    end
  end
end
