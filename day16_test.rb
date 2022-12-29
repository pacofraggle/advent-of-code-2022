require 'minitest/autorun'
require_relative 'day16'

module Advent2022
  class NameTest < Minitest::Test

    def test_from
      pv = ProboscideaVolcanium.from(sample)

      assert_equal ["AA", "BB", "CC", "DD", "EE", "FF", "GG", "HH", "II", "JJ" ], pv.graph.vertices_names
      assert_equal 3, pv.graph.vertex("EE").flow_rate
      assert_equal ["GG"], pv.graph.neighbours_names("HH")
      assert_equal 2, pv.graph.neighbours("II").size
      assert_equal 21, pv.graph.neighbours("II").last.flow_rate
    end

    def test_example_path_progress
      pv = ProboscideaVolcanium.from(sample)
      path = CavePath.new("AA", pv.graph)

      assert_path(path, 0, "AA", ["AA"], 0)
      assert_equal false, path.openable?
      assert_equal 0, path.pressure_release

      path.visit "DD"
      assert_path(path, 1, "DD", ["AA", "DD"], 0)

      res = path.open
      assert_equal true, res
      assert_path(path, 2, "DD", ["AA", "DD", "dd"], 0)
      assert_equal 560, path.pressure_release

      path.visit "CC"
      assert_path(path, 3, "CC", ["AA", "DD", "dd", "CC"], 20)
    
      path.visit "BB"
      assert_path(path, 4, "BB", ["AA", "DD", "dd", "CC", "BB"], 40)

      res = path.open
      assert_equal true, res
      assert_path(path, 5, "BB", ["AA", "DD", "dd", "CC", "BB", "bb"], 60)

      path.visit "AA"
      assert_path(path, 6, "AA", ["AA", "DD", "dd", "CC", "BB", "bb", "AA"], 93)

      path.visit "II"
      assert_path(path, 7, "II", ["AA", "DD", "dd", "CC", "BB", "bb", "AA", "II"], 126)

      path.visit "JJ"
      assert_path(path, 8, "JJ", ["AA", "DD", "dd", "CC", "BB", "bb", "AA", "II", "JJ"], 159)

      res = path.open
      assert_equal true, res
      assert_path(path, 9, "JJ", ["AA", "DD", "dd", "CC", "BB", "bb", "AA", "II", "JJ", "jj"], 192)

      path.visit "II"
      assert_path(path, 10, "II", ["AA", "DD", "dd", "CC", "BB", "bb", "AA", "II", "JJ", "jj", "II"], 246)

      path.visit "AA"
      assert_path(path, 11, "AA", ["AA", "DD", "dd", "CC", "BB", "bb", "AA", "II", "JJ", "jj", "II", "AA"], 300)

      path.visit "DD"
      assert_path(path, 12, "DD", ["AA", "DD", "dd", "CC", "BB", "bb", "AA", "II", "JJ", "jj", "II", "AA", "DD"], 354)

      path.visit "EE"
      assert_path(path, 13, "EE", ["AA", "DD", "dd", "CC", "BB", "bb", "AA", "II", "JJ", "jj", "II", "AA", "DD", "EE"], 408)

      path.visit "FF"
      assert_path(path, 14, "FF", ["AA", "DD", "dd", "CC", "BB", "bb", "AA", "II", "JJ", "jj", "II", "AA", "DD", "EE", "FF"], 462)

      path.visit "GG"
      assert_path(path, 15, "GG", ["AA", "DD", "dd", "CC", "BB", "bb", "AA", "II", "JJ", "jj", "II", "AA", "DD", "EE", "FF", "GG"], 516)

      path.visit "HH"
      assert_path(path, 16, "HH", ["AA", "DD", "dd", "CC", "BB", "bb", "AA", "II", "JJ", "jj", "II", "AA", "DD", "EE", "FF", "GG", "HH"], 570)

      res = path.open
      assert_equal true, res
      assert_path(path, 17, "HH", ["AA", "DD", "dd", "CC", "BB", "bb", "AA", "II", "JJ", "jj", "II", "AA", "DD", "EE", "FF", "GG", "HH", "hh"], 624)

      path.visit "GG"
      assert_path(path, 18, "GG", ["AA", "DD", "dd", "CC", "BB", "bb", "AA", "II", "JJ", "jj", "II", "AA", "DD", "EE", "FF", "GG", "HH", "hh", "GG"], 700)

      path.visit "FF"
      assert_path(path, 19, "FF", ["AA", "DD", "dd", "CC", "BB", "bb", "AA", "II", "JJ", "jj", "II", "AA", "DD", "EE", "FF", "GG", "HH", "hh", "GG", "FF"], 776)

      path.visit "EE"
      assert_path(path, 20, "EE", ["AA", "DD", "dd", "CC", "BB", "bb", "AA", "II", "JJ", "jj", "II", "AA", "DD", "EE", "FF", "GG", "HH", "hh", "GG", "FF", "EE"], 852)

      res = path.open
      assert_equal true, res
      assert_path(path, 21, "EE", ["AA", "DD", "dd", "CC", "BB", "bb", "AA", "II", "JJ", "jj", "II", "AA", "DD", "EE", "FF", "GG", "HH", "hh", "GG", "FF", "EE", "ee"], 928)

      path.visit "DD"
      assert_path(path, 22, "DD", ["AA", "DD", "dd", "CC", "BB", "bb", "AA", "II", "JJ", "jj", "II", "AA", "DD", "EE", "FF", "GG", "HH", "hh", "GG", "FF", "EE", "ee", "DD"], 1007)

      path.visit "CC"
      assert_path(path, 23, "CC", ["AA", "DD", "dd", "CC", "BB", "bb", "AA", "II", "JJ", "jj", "II", "AA", "DD", "EE", "FF", "GG", "HH", "hh", "GG", "FF", "EE", "ee", "DD", "CC"], 1086)

      res = path.open
      assert_equal true, res
      assert_path(path, 24, "CC", ["AA", "DD", "dd", "CC", "BB", "bb", "AA", "II", "JJ", "jj", "II", "AA", "DD", "EE", "FF", "GG", "HH", "hh", "GG", "FF", "EE", "ee", "DD", "CC", "cc"], 1165, true)

      assert_equal 1246, path.pressure_release(25)
      assert_equal 1327, path.pressure_release(26)
      assert_equal 1408, path.pressure_release(27)
      assert_equal 1489, path.pressure_release(28)
      assert_equal 1570, path.pressure_release(29)
      assert_equal 1651, path.pressure_release(30)
    end

    def test_most_pressure_iterative
      pv = ProboscideaVolcanium.from(sample)
      pressure, paths = pv.most_pressure_iterative

      assert_equal 1651, pressure
    end

    def test_example_path_with_elephant_progress
      pv = ProboscideaVolcanium.from(sample)
      path = CavePathWithElephant.new("AA", "AA", pv.graph)

      path.go_open_two("DD", "JJ")
      assert_equal 2, path.time_el
      assert_equal 3, path.time
      assert_equal 20*(26-2) + 21*(26-3), path.pressure_release

      path.go_open_two("HH", "BB")
      assert_equal 7, path.time_el
      assert_equal 7, path.time
      assert_equal 963 + 22*(26-7) + 13*(26-7), path.pressure_release

      path.go_open_two("EE", "CC")
      assert_equal 11, path.time_el
      assert_equal 9, path.time
      assert_equal 1628 + 2*(26-9) + 3*(26-11), path.pressure_release
    end


    def test_most_pressure_with_elephant
      pv = ProboscideaVolcanium.from(sample)
      pressure, paths = pv.most_pressure_iterative(true)

      assert_equal 1707, pressure
    end

    def assert_path(path, time, valve, visited, pressure, finished=false)
      assert_equal time, path.time
      assert_equal valve, path.valve
      assert_equal visited, path.visited
      assert_equal pressure, path.pressure_release(time)
      assert_equal finished, path.finished?
    end

    def sample
      sample = <<EOS
Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II
EOS

      sample
    end

  end
end
