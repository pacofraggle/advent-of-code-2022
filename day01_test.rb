require 'minitest/autorun'
require_relative 'day01'


module Advent2022
  class CaloriesCounterTest < Minitest::Test

    def test_add_calories_line
      assert_equal 24000, calories_counter_sample.max
    end

    def test_top3total
      assert_equal 45000, calories_counter_sample.top3total
    end


    def calories_counter_sample
      sample = <<EOS
1000
2000
3000

4000

5000
6000

7000
8000
9000

10000
EOS
      c = CaloriesCounter.new

      sample.each_line do |line|
        c.add_calories_line(line)
      end

      c
    end
  end
end
