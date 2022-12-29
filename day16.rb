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
      time >= @max || openables.empty?
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

    def potential_max_release
      return @cache[time] if @cache[time]

      final_pressure = potential_release(time)

      @cache[time] = final_pressure

      final_pressure
    end

    def ==(other)
      to_s == other.to_s
    end

    def to_s
      @visited.join("")
    end

    private

    def potential_release(t)
      final_pressure = pressure_release

      potential_openings = (@max-t) / 2
      return final_pressure if potential_openings == 0

      available_valves = @open.select { |k, v| v.nil? }.keys
      return final_pressure if available_valves.empty?

      available_pressure = @pressures.select { |k, v| available_valves.include?(k) }.sort_by { |_, v| v }.reverse.to_a
      0.upto([potential_openings, available_pressure.size].min-1) do |i|
        pressure = available_pressure[i][1]
        from = t + (i+1)#*2
        final_pressure += (@max-from)*pressure
      end

      final_pressure
    end
  end

  class CavePathWithElephant < CavePath
    attr_reader :visited_el

    def initialize(root, root_elephant, graph, open=nil, pressures=nil)
      super(root, graph, open, pressures)

      @visited_el = []
      @visited_el << root_elephant
      @visited_el.flatten!

      @max = 26
    end

    def alternative
      CavePathWithElephant.new(@visited.clone, @visited_el.clone, @graph, @open.clone, @pressures.clone)
    end

    def finished?
      @visited.size == (time >= @max && time_el >= @max) || openables.empty?
    end

    def time_el
      @visited_el.size-1
    end

    def valve_el
      @visited_el.last.upcase
    end

    def openable_el?
      @open.key?(@visited_el.last) && @open[@visited_el.last].nil?
    end

    # Open current
    def open_el
      return false unless openable_el?

      @visited_el << @visited_el.last.downcase
      @open[@visited_el.last.upcase] = time_el

      true
    end

    def go_open_two(dest_el, dest)
      opened_el = go_open_el(dest_el)
      return open_el if dest.nil?

      opened = go_open(dest)

      opened_el || opened
    end

    def go_open_el(dest)
      d = @graph.dist(valve_el, dest)

      return false if (d > @max-(time+1)) || !@open[dest].nil? # +1 because we need to open

      @visited_el += @graph.path(valve_el, dest)
      open_el
    end

    def potential_max_release
      t = [time, time_el].max

      return @cache[t] if @cache[t]

      final_pressure = potential_release(t)

      @cache[t] = final_pressure

      final_pressure
    end

    def to_s
      @visited_el.join("")+" | "+@visited.join("")
    end
  end


  class ProboscideaVolcanium
    attr_reader :graph

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
        @max_path = [] if suggested > @max 
        @max = suggested
        @max_path << path
        #puts "New #{@max}: #{@max_path.last}" if @max_path.size == 1
      end
    end

    def valid?(candidate)
      candidate.potential_max_release >= @max
    end

    def two_candidates_for(path)
      return [] unless valid?(path)

      options = path.openables
      return [] if options.empty?

      if options.size == 1
        pairs = [[ options[0], nil]]
      else
        pairs = options.permutation(2).to_a
      end

      candidates = []
      pairs.each do |pair|
        alt = path.alternative
        opened = alt.go_open_two(pair[0], pair[1])

        candidates << alt if opened && valid?(alt)
      end

      candidates
    end

    def candidates_for(path)
      return [] unless valid?(path)

      candidates = []
      path.openables.each do |missing|
        alt = path.alternative
        opened = alt.go_open(missing)

        candidates << alt if opened && valid?(alt)
      end

      candidates
    end

    def most_pressure_iterative(with_elephant = false)
      @max = -1
      @max_path = []
      root = with_elephant ? CavePathWithElephant.new("AA", "AA", graph) : CavePath.new("AA", graph)
      s = []
      discovered = Set.new
      s.push root
      it = 0
      until s.empty? do
        path = s.pop

        spath = path.to_s
        next if discovered.include?(spath)
        discovered << spath

        next unless valid?(path)

        candidates = with_elephant ? two_candidates_for(path) : candidates_for(path)
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
      end

      return @max, @max_path
    end
  end

  # So, Day16 is the first one I missed because I didn't know how to do
  # Up to date, I had been incrementally building the solution by getting
  # tests for the samples
  # For this day I still have no clue on how the sample was generated so I opted for
  # brute force
  # During the following days I was not able to trim BFS, so I opted for DFS,
  # then trim with the previous max found
  # 
  # Working like that, Part 1 took over 10min (the test 1.7 sec approx)
  # I had added an extra trimming condition taking into account the pressure
  # to be released potentially, but it wasn't good enough
  # I tried then from recursive to iterative, to explore the stack
  # The recursive, even when found, took a while to finished and I suspected
  # it had to do with the backtrace
  #
  # I didn't have many options. I had been evaluating distance between valves
  # and, after uncovering path 2, the path is not really needed so I could try
  # to reduce the amount of candidates going straight from useful valve to valve.
  # That was a whole lot less candidates and useless back-and-forths
  #
  # The trimming function is still useful. It turns a 5s solution into a ms one
  # Now visit and open current are only needed for the tests
  #
  # Orienting the solution to be fully testable has been a mistake here.
  # The sample is one of the several paths that get the optimal route
  #
  # I also had the suspicion that this looked a lot like the Knapsack problem
  class Day16
    def self.run(argv)
      o = ProboscideaVolcanium.from(argv[0])
      starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      pressure, paths = o.most_pressure_iterative
      ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      puts "Part 1: #{pressure}"
      puts "T. Elapsed: #{ending-starting} sec."
      Day16.show_paths(paths)
      puts

      starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      pressure, paths = o.most_pressure_iterative(true)
      ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      puts "Part 2: #{pressure}"
      puts "T. Elapsed: #{ending-starting} sec."
      Day16.show_paths(paths)
    end

    def self.show_paths(paths)
      puts "  Paths:"
      paths.each do |path|
        puts "    #{path}"
      end
    end
  end
end
