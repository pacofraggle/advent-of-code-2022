require 'pry'
require 'set'

module Advent2022

  Valve = Struct.new(:name, :flow_rate, :tunnels, :open)

  class Graph
    INFINITY = 4294967295

    def initialize(label_method, neighbours_method)
      @label_method = label_method
      @neighbours_method = neighbours_method
      @graph = nil
      @labels = nil
      @vertices = nil
    end

    def build(objects)
      @graph = Array.new(objects.size)
      @vertices = Array.new(objects.size)
      0.upto(@graph.size-1) { |i| @graph[i] = Array.new(@graph.size, 0) }

      @labels = {}
      objects.each_with_index do |obj, i|
        @labels[find_label(obj)] = i
        @vertices[i] = obj
      end

      objects.each_with_index do |obj, i|
        p = pos(find_label(obj))
        find_neighbours(obj).each do |n|
          pn = pos(n)
          @graph[p][pn] = 1
        end
      end

      @dist = floyd_warshall
    end

    def vertices
      raise 'Not built yet' unless @vertices

      @vertices
    end

    def vertices_names
      raise 'Not built yet' unless @vertices

      @labels.keys
    end

    def vertex(name)
      raise 'Not built yet' unless @vertices

      @vertices[@labels[name]]
    end

    def dist(origin, dest)
      @dist[@labels[origin]][@labels[dest]]
    end

    def path(origin, dest)
      @paths[@labels[origin]][@labels[dest]]
    end

    def neighbours_names(vertex)
      raise 'Not built yet' unless @vertices

      names = []
      @graph[@labels[vertex]].each_with_index do |v, i|
        next if v == 0
        names << @labels.key(i)
      end

      names
    end

    def neighbours(vertex)
      neighbours_names(vertex).map { |n| vertex(n) }
    end

    def printf
      fprint(@graph)
    end

    def printf
      fprint(@graph)
    end

    def printf_dist
      fprint(@dist)
    end

    private

    def fprint(matrix)
      w = @labels.keys.map { |l| l.size }.max + 1
      puts " ".ljust(w)+"|"+@labels.keys.map { |l| l.rjust(w) }.join("|")
      sep = (@labels.size+1).times.map { "-".ljust(w, "-") }.join("+")
      @labels.each do |l, i|
        puts sep
        puts l.rjust(w)+"|"+matrix[i].map { |gi| gi.to_s.rjust(w) }.join("|")
      end
    end

    def print(matrix)
      matrix.each { |row| puts row.join(', ') }
    end

    def find_label(obj)
      obj.send(@label_method)
    end

    def find_neighbours(obj)
      obj.send(@neighbours_method)
    end

    def pos(label)
      @labels[label]
    end

    def floyd_warshall
      dist = Array.new(@graph.size)
      0.upto(@graph.size-1) { |i| dist[i] = Array.new(@graph.size, INFINITY) }
      nexts = Array.new(@graph.size)
      0.upto(@graph.size-1) { |i| nexts[i] = Array.new(@graph.size, nil) }

      @graph.each_with_index do |row, i|
        row.each_with_index do |cell, j|
          next unless cell == 1
          dist[i][j] = 1
          nexts[i][j] = j
        end
      end
      0.upto(@graph.size-1) do |i|
        dist[i][i] = 0
        nexts[i][i] = i
      end

      0.upto(@graph.size-1) do |k|
        0.upto(@graph.size-1) do |i|
          0.upto(@graph.size-1) do |j|
            if dist[i][j] > dist[i][k] + dist[k][j]
              dist[i][j] = dist[i][k] + dist[k][j]
              nexts[i][j] = nexts[i][k]
            end
          end
        end
      end

      compile_paths(nexts)
      dist
    end

    def compile_paths(nexts)
      @paths = Array.new(@graph.size)
      0.upto(@graph.size-1) { |i| @paths[i] = Array.new(@graph.size, nil) }

      0.upto(@graph.size-1) do |i|
        0.upto(@graph.size-1) do |j|
          if nexts[i][j].nil?
            @paths[i][j] = nil
          else
            u = i
            dest = @labels.key(j)
            node = @labels.key(u)
            path = [node]
            until node == dest
              u = nexts[u][j]
              node = @labels.key(u)
              path << node
            end
            path.shift
            @paths[i][j] = path
          end
        end
      end
    end

  end

  class CavePath
    attr_reader :visited, :open
    def initialize(root, graph, open=nil, pressures=nil)
      @visited = []
      @visited << root
      @visited.flatten!

      if open.nil?
        @open = {}
        graph.vertices.select { |v| v.flow_rate > 0 && !v.open }.each { |v| @open[v.name] = nil }
      else
        @open = open
      end

      if pressures.nil?
        @pressures = {}
        graph.vertices.select { |v| v.flow_rate > 0 && !v.open }.each { |v| @pressures[v.name] = v.flow_rate }
      else
        @pressures = pressures
      end
      @graph = graph
      @cache = {}
      @max = 30
    end

    def alternative
      CavePath.new(@visited.clone, @graph, @open.clone, @pressures.clone)
    end

    def finished?
      @visited.size == @max|| @open.find { |_, v| v.nil? }.nil?
    end

    def time
      @visited.size-1
    end

    def valve
      @visited.last.upcase
    end

    # Adjacent expected
    def visit(valve)
      raise 'Already finished' if finished?

      @visited << valve
    end

    def openables
      @open.select { |v, t| t.nil? }.keys
    end

    # Open current
    def openable?
      @open.key?(@visited.last) && @open[@visited.last].nil?
    end

    # Open current
    def open
      return false unless openable?

      @visited << @visited.last.downcase
      @open[@visited.last.upcase] = time

      true
    end

    def go_open(dest)
      d = @graph.dist(valve, dest)

      return false if (d > @max-(time+1)) || !@open[dest].nil? # +1 because we need to open

      @visited += @graph.path(valve, dest)
      open
    end

    def pressure_release(upto=@max)
      total = 0
      @open.select { |_, t| !t.nil? && t < upto }.each do |v, t|
        total += (upto - t)*@pressures[v]
      end

      total
    end

    # Not needed
    def potential_max_release
      return @cache[time] if @cache[time]

      final_pressure = pressure_release

      potential_openings = (@max-time) / 2
      if potential_openings == 0
        @cache[time] = final_pressure
        return @cache[time]
      end

      available_valves = @open.select { |k, v| v.nil? }.keys
      if available_valves.empty?
        @cache[time] = final_pressure
        return @cache[time]
      end

      available_pressure = @pressures.select { |k, v| available_valves.include?(k) }.sort_by { |_, v| v }.reverse.to_a
      0.upto([potential_openings, available_pressure.size].min-1) do |i|
        pressure = available_pressure[i][1]
        from = time + (i+1)#*2
        final_pressure += (@max-from)*pressure
      end

      @cache[time] = final_pressure
      final_pressure
    end

    def ==(other)
      to_s == other.to_s
    end

    def to_s
      @visited.join("")
    end
  end

  class ProboscideaVolcanium

    attr_reader :graph, :valves

    def initialize(valves)
      @graph = Graph.new(:name, :tunnels)
      @graph.build(valves)
      @valves = valves
    end

    def self.from(data)
      data = File.read(data) if File.exist?(data)

      valves = []
      data.each_line do |line|
        l = line.strip
        words = l.split(/ /)
        name = words[1]
        flow = words[4].split(/=/)[1].gsub(/;/, '').to_i
        tunnels = words[9..-1].map { |v| v.gsub(/,/, '') }

        valves << Valve.new(name, flow, tunnels, false)
      end

      ProboscideaVolcanium.new(valves)
    end

    def register_max(path)
      suggested = path.pressure_release

      if suggested >= @max
        @max = suggested
        @max_path << path
        puts "New #{@max}: #{@max_path.last}"
      end
    end

    def valid?(candidate)
      candidate.potential_max_release >= @max
    end

    def candidates_for(path)
      candidates = []

      return candidates unless valid?(path)

      current = path.valve
      path.openables.each do |missing|
        alt = path.alternative
        opened = alt.go_open(missing)

        candidates << alt if opened #&& valid?(alt)
      end

      candidates
    end

    def most_pressure_iterative
      @max = -1
      @max_path = []
      root = CavePath.new("AA", graph)
      s = []
      #discovered = Set.new
      s.push root
      it = 0
      until s.empty? do
        path = s.pop

        #spath = path.to_s
        #next if discovered.include?(spath)
        #discovered << spath

        #next unless path.potential_max_release > @max

        candidates = candidates_for(path)
        if candidates.empty?
          register_max(path)
          next
        end

        candidates.each do |alt|
          if alt.finished?
            register_max(alt)
            next
          end
          s.push alt
        end
        it += 1
        #puts "s = #{s.size} in #{it} t=#{candidates.last.time}"
      end

      return @max, @max_path
    end
  end

  class Day16
    def self.run(argv)
      o = ProboscideaVolcanium.from(argv[0])
      starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      pressure, paths = o.most_pressure_iterative
      ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      puts "Part 1: #{pressure}. T. Elapsed: #{ending-starting} sec."

      puts "Part 2: NOT YET"
    end
  end
end
