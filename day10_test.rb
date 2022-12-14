require 'minitest/autorun'
require_relative 'day10'

module Advent2022
  class CatodeRayTest < Minitest::Test


    def test_small_sample
      cr = CatodeRay.new

      assert_equal 1, cr.X(1)

      cr.noop
      assert_equal 1, cr.X(2)

      cr.addx 3
      assert_equal 1, cr.X(2)
      assert_equal 1, cr.X(3)
      assert_equal 4, cr.X(4)

      cr.addx -5
      assert_equal 4, cr.X(4)
      assert_equal 4, cr.X(5)
      assert_equal -1, cr.X(6)
    end

    def test_signal_strengths
      cr = read(larger_sample)

      assert_equal 21, cr.X(20)
      assert_equal 420, cr.signal_strength(20)
      assert_equal 19, cr.X(60)
      assert_equal 1140, cr.signal_strength(60)
      assert_equal 18, cr.X(100)
      assert_equal 1800, cr.signal_strength(100)
      assert_equal 21, cr.X(140)
      assert_equal 2940, cr.signal_strength(140)
      assert_equal 16, cr.X(180)
      assert_equal 2880, cr.signal_strength(180)
      assert_equal 18, cr.X(220)
      assert_equal 3960, cr.signal_strength(220)

      assert_equal 13140, cr.signal_strength_sum([20, 60, 100, 140, 180, 220])
    end

    def test_crt_row_for
      crt = CatodeRay::CRT.new

      assert_equal 0, crt.row_for(1)
      assert_equal 0, crt.row_for(40)
      assert_equal 1, crt.row_for(41)
      assert_equal 1, crt.row_for(80)
      assert_equal 2, crt.row_for(81)
      assert_equal 2, crt.row_for(120)
      assert_equal 3, crt.row_for(121)
      assert_equal 3, crt.row_for(160)
      assert_equal 4, crt.row_for(161)
      assert_equal 4, crt.row_for(200)
      assert_equal 5, crt.row_for(201)
      assert_equal 5, crt.row_for(240)
    end

    def test_CRT_sample
      cr = CatodeRay.new

      cr.addx 15
      assert cr.crt_row(0).start_with?("##")
      cr.addx -11
      assert cr.crt_row(0).start_with?("##..")
      cr.addx 6
      assert cr.crt_row(0).start_with?("##..##")
      cr.addx -3
      assert cr.crt_row(0).start_with?("##..##..")
      cr.addx 5
      assert cr.crt_row(0).start_with?("##..##..##")
      cr.addx -1
      assert cr.crt_row(0).start_with?("##..##..##..")
      cr.addx -8
      assert cr.crt_row(0).start_with?("##..##..##..##")
      cr.addx 13
      assert cr.crt_row(0).start_with?("##..##..##..##..")
      cr.addx 4
      assert cr.crt_row(0).start_with?("##..##..##..##..##")
      cr.noop
      assert cr.crt_row(0).start_with?("##..##..##..##..##.")
      cr.addx -1
      assert cr.crt_row(0).start_with?("##..##..##..##..##..#")
    end

    def test_CRT_sample2
      cr = read(larger_sample)

      expected = <<EOS
##..##..##..##..##..##..##..##..##..##..
###...###...###...###...###...###...###.
####....####....####....####....####....
#####.....#####.....#####.....#####.....
######......######......######......####
#######.......#######.......#######.....
EOS

      assert_equal expected, cr.crt
    end


    def larger_sample
      sample = <<EOS
addx 15
addx -11
addx 6
addx -3
addx 5
addx -1
addx -8
addx 13
addx 4
noop
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx -35
addx 1
addx 24
addx -19
addx 1
addx 16
addx -11
noop
noop
addx 21
addx -15
noop
noop
addx -3
addx 9
addx 1
addx -3
addx 8
addx 1
addx 5
noop
noop
noop
noop
noop
addx -36
noop
addx 1
addx 7
noop
noop
noop
addx 2
addx 6
noop
noop
noop
noop
noop
addx 1
noop
noop
addx 7
addx 1
noop
addx -13
addx 13
addx 7
noop
addx 1
addx -33
noop
noop
noop
addx 2
noop
noop
noop
addx 8
noop
addx -1
addx 2
addx 1
noop
addx 17
addx -9
addx 1
addx 1
addx -3
addx 11
noop
noop
addx 1
noop
addx 1
noop
noop
addx -13
addx -19
addx 1
addx 3
addx 26
addx -30
addx 12
addx -1
addx 3
addx 1
noop
noop
noop
addx -9
addx 18
addx 1
addx 2
noop
noop
addx 9
noop
noop
noop
addx -1
addx 2
addx -37
addx 1
addx 3
noop
addx 15
addx -21
addx 22
addx -6
addx 1
noop
addx 2
addx 1
noop
addx -10
noop
noop
addx 20
addx 1
addx 2
addx 2
addx -6
addx -11
noop
noop
noop
EOS

      return sample
    end

    def read(sample)
      o = CatodeRay.new

      sample.each_line do |line|
        o.read_line(line)
      end

      o
    end
  end
end
