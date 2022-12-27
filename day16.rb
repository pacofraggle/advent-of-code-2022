require 'pry'

module Advent2022

  Valve = Struct.new(:name, :flow_rate, :tunnels, :open)

  class Graph
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
    end

    def vertices
      raise 'Not built yet' unless @vertices

      @labels.keys
    end

    def vertex(name)
      raise 'Not built yet' unless @vertices

      @vertices[@labels[name]]
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

    def print
      w = @labels.keys.map { |l| l.size }.max + 1
      puts " ".ljust(w)+"|"+@labels.keys.map { |l| l.rjust(w) }.join("|")
      sep = (@labels.size+1).times.map { "-".ljust(w, "-") }.join("+")
      @labels.each do |l, i|
        puts sep
        puts l.rjust(w)+"|"+@graph[i].map { |gi| gi.to_s.rjust(w) }.join("|")
      end
    end

    private

    def find_label(obj)
      obj.send(@label_method)
    end

    def find_neighbours(obj)
      obj.send(@neighbours_method)
    end

    def pos(label)
      @labels[label]
    end
  end

  class CavePath
    attr_reader :visited, :open
    MAX = 30
    def initialize(root, valves, open=nil, pressures=nil)
      @visited = []
      @visited << root
      @visited.flatten!

      if open.nil?
        @open = {}
        valves.select { |v| v.flow_rate > 0 && !v.open }.each { |v| @open[v.name] = nil }
      else
        @open = open
      end

      if pressures.nil?
        @pressures = {}
        valves.select { |v| v.flow_rate > 0 && !v.open }.each { |v| @pressures[v.name] = v.flow_rate }
      else
        @pressures = pressures
      end
    end

    def alternative
      CavePath.new(@visited.clone, nil, @open.clone, @pressures.clone)
    end

    def finished?
      @visited.size == MAX || @open.find { |_, v| v.nil? }.nil?
    end

    def visit(valve)
      raise 'Already finished' if finished?

      @visited << valve
    end

    def time
      @visited.size-1
    end

    def valve
      @visited.last.upcase
    end

    def openable?
      @open.key?(@visited.last) && @open[@visited.last].nil?
    end

    def open
      return false unless openable?

      @visited << @visited.last.downcase
      @open[@visited.last.upcase] = time

      true
    end

    def pressure_release(upto=MAX)
      total = 0
      @open.select { |_, t| !t.nil? && t < upto }.each do |v, t|
        total += (upto - t)*@pressures[v]
      end

      total
    end

    def potential_max_release
      final_pressure = pressure_release
      potential_openings = (MAX-time) / 2
      return pressure_release if potential_openings == 0

      available_valves = @open.select { |k, v| v.nil? }.keys

      return pressure_release if available_valves.empty?

      available_pressure = @pressures.select { |k, v| available_valves.include?(k) }.sort_by { |_, v| v }.reverse.to_a
      0.upto([potential_openings, available_pressure.size].min-1) do |i|
        pressure = available_pressure[i][1]
        from = time + (i+1)#*2
        final_pressure += (MAX-from)*pressure
      end

      final_pressure
    end

    #def ==(other)
    #  @visited == other.visited && @open == other.open
    #end

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

    def record_max(path)
      suggested = path.pressure_release
      if suggested > @max
        @max = suggested
        @max_path = [path]
        puts "New #{@max}: #{@max_path.first}"
        return true
      end

      if suggested == @max
        @max_path << path
        #puts "New #{@max}: #{@max_path.last}"
        return true
      end

      false
    end

    def valid?(candidate)
      candidate.potential_max_release >= @max
    end

    def max_pressure(path)
      if path.finished?
        record_max(path)
        return
      end

      return unless valid?(path)

      candidates = []
      if path.openable?
        alt = path.alternative
        alt.open
        candidates << alt
      end
      current = path.valve
      @graph.neighbours_names(current).each do |neigh|
        alt = path.alternative
        alt.visit neigh
        candidates << alt if valid?(alt)
      end

      if candidates.empty?
        record_max(path)
        return
      end

      #candidates.sort_by! { |alt| @graph.vertex(alt.valve).flow_rate }

      candidates_pressures = []
      candidates.each do |path|
        #if path.finished?
        #  candidates_pressures << path.pressure_release
        #else
        max_pressure(path)
        #  options_pressures << max_pressure(path)
        #end
      end

      #max = options_pressures.max
      #index = options_pressures.index(max)
      #record_max(max, options[index])
    end

    def most_pressure
      @max = -1
      @max_path = nil
      v = CavePath.new("AA", valves)

      max_pressure(v)

      return @max, @max_path
    end
  end

  class Day16
    def self.run(argv)
      o = ProboscideaVolcanium.from(argv[0])
      starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      pressure, paths = o.most_pressure
      ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      puts "Part 1: #{pressure}. T. Elapsed: #{ending-starting} sec."

      puts "Part 2: NOT YET"
    end
  end
end
