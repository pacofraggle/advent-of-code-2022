require 'minitest/autorun'
require_relative 'day07'

module Advent2022
  class DeviceTest < Minitest::Test

    def test_line_cd
      line = Device::Line.new("$ cd /")

      assert_equal true, line.cd?
      assert_equal "cd", line.command
      assert_equal "/", line.name
      assert_equal false, line.dir?
      assert_equal false, line.file?
    end

    def test_line_dir
      line = Device::Line.new("dir a")

      assert_equal true, line.dir?
      assert_equal "a", line.name
      assert_equal false, line.cd?
      assert_equal false, line.file?
    end

    def test_line_file
      line = Device::Line.new("1234 abc")

      assert_equal true, line.file?
      assert_equal "abc", line.name
      assert_equal 1234, line.size
      assert_equal false, line.cd?
      assert_equal false, line.dir?
    end

    def test_add_terminal_line
      d = terminal_sample(5)

      assert_equal 23352670, d.size("/")
      assert_equal 0, d.size("/a")
      assert_equal 0, d.size("/d")

      d = terminal_sample(11)

      assert_equal 23446939, d.size("/")
      assert_equal 94269, d.size("/a")
      assert_equal 0, d.size("/d")

      d = terminal_sample(14)

      assert_equal 23447523, d.size("/")
      assert_equal 94853, d.size("/a")
      assert_equal 0, d.size("/d")
      assert_equal 584, d.size("/a/e")

      d = terminal_sample

      assert_equal 48381165, d.size("/")
      assert_equal 94853, d.size("/a")
      assert_equal 24933642, d.size("/d")
      assert_equal 584, d.size("/a/e")
    end

    def terminal_sample(lines=nil)
      sample = <<EOS
$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k
EOS
      o = Device.new

      top = lines.nil? ? 1000000 : lines
      i = 0
      sample.each_line do |line|
        o.add_terminal_line(line)
        i += 1
        break if i > top
      end

      o
    end
  end
end
