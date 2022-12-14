require 'set'

module Advent2022
  class Node
    attr_accessor :i, :j, :value, :neighbours

    MIN_HEIGHT_LETTER = 'a'.ord
    MAX_HEIGHT_LETTER = 'z'.ord
    LETTERS_RANGE = MAX_HEIGHT_LETTER - MIN_HEIGHT_LETTER

    def initialize(i, j, value)
      @i = i
      @j = j
      @value = value
      @neighbours = []
      @height = nil
    end

    def height
      @height ||= height_from_value
    end

    def add_neighbour(node)
      @neighbours << node
    end

    def self.letter_to_height(ch)
      ch.ord - MIN_HEIGHT_LETTER
    end

    def self.letter_reversed(ch)
      if ch == 'E'
        'S'
      elsif ch == 'S'
        'E'
      else
        #((LETTERS_RANGE - Node.letter_to_height(ch)) + MIN_HEIGHT_LETTER).chr
        (MAX_HEIGHT_LETTER - ch.ord + MIN_HEIGHT_LETTER).chr
      end
    end

    def to_s
      "(#{i}, #{j}) #{value} : #{height} #{neighbours.map {|n| n.value }}"
    end

    private

    def height_from_value
      if value == 'S'
        0
      elsif value == 'E'
        #Node.letter_to_height('z')
        LETTERS_RANGE
      else
        Node.letter_to_height(value)
      end
    end
  end

  class Graph
    attr_accessor :nodes, :initial, :destination

    INFINITY = 4294967295

    def initialize(rows, cols)
      @nodes = Array.new(rows)
      0.upto(rows-1) { |i| @nodes[i] = Array.new(cols) }
    end

    def add_node(i, j, value)
      node = Node.new(i, j, value)
      @nodes[i][j] = node

      @initial = node if node.value == 'S'
      @destination = node if node.value == 'E'

      node
    end

    def node(i, j)
      @nodes[i][j]
    end

    def set_node_neighbours
      nodes.each_with_index do |row, i|
        row.each_with_index do |v, j|
          current = node(i, j)
          possible_neighbours = next_to(i, j)
          
          possible_neighbours.each do |pn|
            current.add_neighbour(pn) if pn.height <= current.height+1
          end
        end
      end
    end

    def shortest_path
      dijkstra[destination.i][destination.j]
    end

    def dijkstra
      @dijkstra ||= dijkstra_algorithm
    end

    def find_nodes(letter)
      list = []
      0.upto(rows-1) do |row|
        0.upto(cols-1) do |col|
          n = node(row, col)
          list << n if n.height == Node.letter_to_height(letter)
        end
      end

      list
    end

    private

    def next_to(i, j)
      possible = []
      possible << node(i-1, j) if i > 0
      possible << node(i+1, j) if i < @nodes.size-1
      possible << node(i, j-1) if j > 0
      possible << node(i, j+1) if j < @nodes[i].size-1

      possible
    end

    def dijkstra_algorithm
      q = Set.new
      dist = Array.new(rows)
      #prev = Array.new(rows)
      0.upto(rows-1) do |i|
        dist[i] = Array.new(cols, INFINITY-1)
        #prev[i] = Array.new(cols, nil)
        @nodes[i].each { |n| q << n }
      end

      dist[initial.i][initial.j] = 0
  
      until q.empty? do
        min_dist = INFINITY
        min = nil
        q.each do |node|
          d = dist[node.i][node.j]
          if d < min_dist
            min_dist = d
            min = node
          end
        end

        raise 'Panic' if min.nil?
        q.delete(min)

        min.neighbours.each do |v|
          next unless q.include?(v)
          alt = dist[min.i][min.j] + 1
          if alt < dist[v.i][v.j]
            dist[v.i][v.j] = alt
            #prev[v.i][v.j] = min
          end
        end
      end

      dist
    end

    def rows
      @nodes.size
    end

    def cols
      @nodes[0].size
    end
  end

  class HillClimbing
    attr_reader :graph

    def initialize(grid)
      @graph = Graph.new(grid.size, grid[0].size)

      grid.each_with_index do |row, i|
        row.each_with_index do |val, j|
          @graph.add_node(i, j, val)
        end
      end

      @graph.set_node_neighbours
    end

    def self.from_grid(data)
      data = File.read(data) if File.exist?(data)
      grid = []
      data.each_line { |line| grid << line.strip.chars }

      HillClimbing.new(grid)
    end

    def self.from_grid_reverse(data)
      data = File.read(data) if File.exist?(data)
      grid = []
      data.each_line do |line|
        grid << line.strip.chars.map { |ch| Node.letter_reversed(ch) }
      end

      HillClimbing.new(grid)
    end

    def shortest_path
      graph.shortest_path
    end
  
    def shortest_path_to_letter(letter)
      dists = graph.dijkstra
      list = graph.find_nodes(letter)
      list.map { |node| dists[node.i][node.j] }.min
    end
  end

  class Day12
    def self.run(argv)
      hc = HillClimbing.from_grid(argv[0])
      puts "Part 1: #{hc.shortest_path}"

      # With method 2 both parts can be solved
      hc = HillClimbing.from_grid_reverse(argv[0])
      puts "Part 2: #{hc.shortest_path_to_letter('z')}"
      puts "Part 1: #{hc.shortest_path} (as part of 2 solution)"
    end
  end
end
