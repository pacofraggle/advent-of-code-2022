require 'minitest/autorun'
require_relative 'day24'

module Advent2022
  class BlizzardBasinTest < Minitest::Test

    def test_from
      bb = BlizzardBasin.from(sample)

      ##assert_equal sample.rstrip, bb.valley.area.join("\n")

      bb.valley.print
puts "--------"
      bb.valley.at(1)
      bb.valley.print

      bb.valley.at(2)
      bb.valley.print

      bb.valley.at(3)
      bb.valley.print

      bb.valley.at(4)
      bb.valley.print

      bb.valley.at(5)
      bb.valley.print
    end

    def test_complex
      bb = BlizzardBasin.from(complex_sample)

      bb.find_routes
    end

    def sample
      sample = <<EOS
#.#####
#.....#
#>....#
#.....#
#...v.#
#.....#
#####.#
EOS

      sample
    end

    def complex_sample
      sample = <<EOS
#.######
#>>.<^<#
#.<..<<#
#>v.><>#
#<^v^^>#
######.#
EOS

      sample
    end
  end
end
