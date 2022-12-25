require 'minitest/autorun'
require_relative 'day25'

module Advent2022
  class FullHotAirTest < Minitest::Test

    def test_from
      fha = FullHotAir.from(sample)
     
      assert_equal 13, fha.levels.size
    end

    def test_from_s
      value = "2=-01"
      s = Snafu.new(value)

      assert_equal 976, s.to_i
      assert_equal value, s.to_s
    end

    def test_from_s_sample
      fha = FullHotAir.from(sample)
     
      fha.levels.each_with_index do |l, i|
        assert_equal sample_to_i[i], l.to_i
      end
    end

    def test_from_s_brochure
      fha = FullHotAir.from(brochure)
     
      fha.levels.each_with_index do |l, i|
        assert_equal brochure_to_i[i], l.to_i
      end
    end

    def test_sum
      fha = FullHotAir.from(sample)
     
      assert_equal 4890, fha.sum
    end

    def test_to_i_from_brochure
      fha = FullHotAir.from(brochure)

      brochure_to_i.each_with_index do |b, i|
        assert_equal b, fha.levels[i].to_i
      end
    end

    def test_to_i_from_sample
      fha = FullHotAir.from(sample)

      sample_to_i.each_with_index do |b, i|
        assert_equal b, fha.levels[i].to_i
      end
    end


    def test_xxx
      Snafu.i_to_s(2022)
    end


    def sample
      sample = <<EOS
1=-0-2
12111
2=0=
21
2=01
111
20012
112
1=-1=
1-12
12
1=
122
EOS

      sample
    end

    def brochure
      sample = <<EOS
1
2
1=
1-
10
11
12
2=
2-
20
1=0
1-0
1=11-2
1-0---0
1121-1110-1=0
EOS

      sample
    end

    def sample_to_i
      [1747, 906, 198, 11, 201, 31, 1257, 32, 353, 107, 7, 3, 37]
    end

    def brochure_to_i
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 2022, 12345, 314159265]
    end
  end
end
