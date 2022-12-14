module Advent2022
  class Device
    class Line
      attr_reader :command, :size, :name

      def initialize(line)
        words = line.split(/ /)
        if words[0] == "$"
          @command = words[1]
          @name = words[2]
        elsif words[0] == "dir"
          @size = -1
          @name = words[1]
        else
          @size = words[0].to_i
          @name = words[1]
        end
      end

      def cd?
        @command == "cd"
      end

      def dir?
        @size == -1
      end

      def file?
        !dir? && !@command
      end
    end

    DirFile = Struct.new(:name, :size)

    attr_reader :current_folder, :tree

    def initialize
      @current_folder = nil
      @tree = {}
    end

    def self.from_file(name)
      r  = Device.new

      File.readlines(name).each do |line|
        r.add_terminal_line(line)
      end

      r
    end

    def add_terminal_line(line)
      l = Line.new(line.strip)

      if l.cd?
        @current_folder = changed_folder(l.name)
        @tree[@current_folder] ||= []
      elsif l.dir?
        @tree[changed_folder(l.name)] ||= []
      elsif l.file?
        file = DirFile.new(l.name, l.size)
        @tree[@current_folder] << file unless @tree[@current_folder].include?(file) 
      end
    end  

    def size(folder)
      subfolders(folder).reduce(0) do |acc, current|
        acc + folder_files_size(current)
      end
    end

    def folder_files_size(folder)
      @tree[folder].reduce(0) { |acc, current| acc + current.size }
    end

    def subfolders(folder)
      @tree.keys.select do |current|
        current.start_with?(folder)
      end
    end

    def part1
      @tree.keys.reduce(0) do |acc, folder|
        size = size(folder)
        add = size <= 100000 ? size : 0
        acc + add
      end
    end

    def part2
      total_space = 70000000
      required_space = 30000000
      used_space = size("/")
      puts "  Total:     #{total_space}"
      puts "  Required:  #{required_space}"
      puts "  Used:      #{used_space}"
      puts "  Available: #{total_space-used_space}"
      delete_space = required_space-(total_space-used_space)
      puts "  Delete:    #{delete_space}"

      bigger = @tree.keys.map do |folder|
        size = size(folder)
        size if size > delete_space
      end.compact.min

      puts "  Smaller:   #{bigger}"
    end

    private

    def changed_folder(name)
      if name.start_with?("/")
        name
      elsif name == ".."
        go_back_folder(@current_folder)
      else
        add_folder(@current_folder, name)
      end
    end

    def add_folder(root, folder)
      path = folders_path(root)
      path << folders_path(folder)

      ("/"+path.join("/")).gsub(/\/\//, "/")
    end

    def go_back_folder(folder)
      path = folders_path(folder)

      ("/"+path[0..-2].join("/")).gsub(/\/\//, "/")
    end

    def folders_path(name)
      name.split(/\//).compact
    end
  end


  class Day07
    def self.run(argv)
      device = Device.from_file(argv[0])
      puts "Part1: #{device.part1}"
      puts "Part2:"
      device.part2
    end
  end
end
