require 'set'

module Advent2022

  Valve = Struct.new(:name, :flow_rate, :tunnels, :open)

  class Graph
    def initialize(label_method, neighbours_method)
      @label_method = label
      @neighbours_method = neigbhours
    end
    
    def build(objects)
      @graph = Array.new(objects.size)
      0.upto(@graph.size-1) { |i| @graph[i] = Array.new(@graph.size, 0) }

      @labels = {}
      objects.each_with_index { |obj, i| @labels[label(obj)] = i }
      objects.each_with_index do |obj, i| 
        p = pos(label(obj))
        neighbours(obj).each do |n|
          pn = pos(n)
          @graph[p][pn] = 1
        end
      end
    end

    private

    def label(obj)
      obj.send(@label_method)
    end

    def neighbours(obj)
      obj.send(@neighbours)
    end


    def pos(label)
      @labels[label]
    end

  end

  class ProboscideaVolcanium
  

    def initialize(valves)
      @graph = Graph.new(:name, :tunnels)
      @graph.build(valves)
    end

    def add_valve(valve)
      @valves[valve.name] = valve
    end

    def self.from(data)
      data = File.read(data) if File.exist?(data)

      valves = []

      data.each_line do |line|
        l = line.strip
        words = l.split(/ /)
        name = words[1]
        flow = words[4].split(/=/)[1].gsub(/;/, '').to_i
        tunnels[name] = words[9..-1].map { |v| v.gsub(/,/, '') }
        
        valves << Valve.new(words[1], flow, tunnels, false)
      end

      ProboscideaVolcanium.new(valves)
    end

  end

  class Day16
    def self.run(argv)
      puts "NOT YET"
      #o = ProboscideaVolcanium.from(argv[0])
    end
  end
end
