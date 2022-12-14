require 'minitest/autorun'
require_relative 'day05'

module Advent2022
  class CargoCratesTest < Minitest::Test

    def test_moves
      move = CargoCrates::Move.new(5, 2, 4)

      assert_equal 5, move.amount
      assert_equal 2, move.from
      assert_equal 4, move.to
      assert_equal "move 5 from 2 to 4", move.to_s
    end

    def test_stack
      s = CargoCrates::Stack.new
      s.stack('A')
      s.stack('B')

      assert_equal 'AB', s.to_s

      s.unstack
      s.stack('C')
      assert_equal 'AC', s.to_s
    end

    def test_read_moves
      moves = CargoCrates.read_moves('sample-day05')

      assert_equal 4, moves.size
      assert_equal CargoCrates::Move.new(1, 2, 1), moves[0]
      assert_equal CargoCrates::Move.new(3, 1, 3), moves[1]
      assert_equal CargoCrates::Move.new(2, 2, 1), moves[2]
      assert_equal CargoCrates::Move.new(1, 1, 2), moves[3]
    end

    def test_read_setup
      setup = CargoCrates.read_setup('sample-day05')

      assert_equal 3, setup.size
      assert_equal 'ZN', setup[0].to_s
      assert_equal 'MCD', setup[1].to_s
      assert_equal 'P', setup[2].to_s
    end

    def test_status
      cargo = CargoCrates.from_file('sample-day05')

      assert_equal ['ZN', 'MCD', 'P'], cargo.status
    end

    def test_move_1
      cargo = CargoCrates.from_file('sample-day05')
      cargo.run(1)

      assert_equal ["ZND", "MC", "P"], cargo.status
      assert_equal "DCP", cargo.top_crates
    end 

    def test_move_2
      cargo = CargoCrates.from_file('sample-day05')
      cargo.run(2)

      assert_equal ["", "MC", "PDNZ"], cargo.status
      assert_equal " CZ", cargo.top_crates
    end 

    def test_move_3
      cargo = CargoCrates.from_file('sample-day05')
      cargo.run(3)

      assert_equal ["CM", "", "PDNZ"], cargo.status
      assert_equal "M Z", cargo.top_crates
    end 

    def test_move_4
      cargo = CargoCrates.from_file('sample-day05')
      cargo.run(4)

      assert_equal ["C", "M", "PDNZ"], cargo.status
      assert_equal "CMZ", cargo.top_crates
    end 

    def test_run
      cargo = CargoCrates.from_file('sample-day05')
      cargo.run

      assert_equal ["C", "M", "PDNZ"], cargo.status
      assert_equal "CMZ", cargo.top_crates
    end

    def test_run_9001
      cargo = CargoCrates.from_file('sample-day05')
      cargo.run_9001

      assert_equal ["M", "C", "PZND"], cargo.status
      assert_equal "MCD", cargo.top_crates
    end
  end
end
