require 'set'

module Advent2022

  class Valve
    attr_reader :name, :flow_rate, :tunnels
    attr_accessor :open

    def initialize(name, flow_rate)
      @name = name
      @flow_rate = flow_rate
      @open = false
      @tunnels = []
    end

    def add_tunnel_to(valve)
      @tunnels << valve
    end
  end

  class ProboscideaVolcanium
  
    attr_reader :valves

    def initialize
      @valves = {}
    end

    def add_valve(valve)
      @valves[valve.name] = valve
    end

    def self.from(data)
      data = File.read(data) if File.exist?(data)

      valves = {}
      tunnels = {}

      o = ProboscideaVolcanium.new
      data.each_line do |line|
        l = line.strip
        words = l.split(/ /)
        name = words[1]
        flow = words[4].split(/=/)[1].gsub(/;/, '').to_i
        tunnels[name] = words[9..-1].map { |v| v.gsub(/,/, '') }

        o.add_valve(Valve.new(words[1], flow))
      end

      o.valves.each do |name, v|
        tunnels[name].each { |d| v.add_tunnel_to(o.valves[d]) }
      end

      o
    end

    def opened_valves
      valves.values.select { |v| v.open }.map { |v| v.name }
    end

    def release_valves(starting, minutes)
      @releasing_pressure = 0
      @minute = 0
      @minutes = minutes
      valves.each { |_, v| v.open = false }

      @current_valve = valves[starting]
      visit(@current_valve)
    end

    def visit(valve)
      puts "visit #{valve.name} #{minute}"
      @current_valve = valve
      if !valve.open && valve.flow_rate > 0
        valve.open = true
        @minutes += 1
      end

      return if minute == @minutes

      @current_valve.tunnels.each do |v|
        @minute += 1
        visit(v)
        return if minute == @minutes
      end
    end

    def path(root)
      v = valves[root]
      puts v.tunnels.first.name

      releases = []
      v.tunnels.each do |adj|
puts "from #{adj.name} ================================"
        @discovered = Set.new
        @stack = []
        @path = []
        @ignore = false
        traverse(adj)

        puts list(@path)
        puts list(@stack)
        idxs = @path.each_index.select { |i| @path[i] == adj }
        spaths = idxs[0..-2].map { |idx| @path[idx..-1] }

        spaths.each do |path| 
          releasing = Array.new(31, 0)
          min = open_valves(path, 0, releasing)
          if min < 30 && closed?
            if @stack.first == adj
              open_valves(Array.new(@stack[1..-1]), min, releasing)
            end
          end
          complete(releasing)
          releases << releasing.sum
          close_all
        end
      end

      puts releases.to_s
      puts releases.max
    end
    
    def complete(releasing)
      max = releasing.max
      found = false
      releasing.each_with_index do |value, i|
        if value == max
          found = true
        end
        releasing[i] = max if found
      end
    end

    def traverse(v)
      @discovered << v
      #puts "#{v.name}"
      @stack.push(v)
      @path << v
      #puts "stack: "+list(@stack)
      #puts "    PATH: "+list(@path)

      v.tunnels.each do |adj|
        if !@discovered.include?(adj)
          traverse(adj)
          if v == @stack.first
            @ignore = false
          end
          unless @ignore
            @stack.pop
            @path << v
            #puts "  back to #{v.name} "+list(@stack)
            #puts "    PATH: "+list(@path)
            @ignore = @stack.first.tunnels.include?(v) 
          end
        end
      end
    end

    def open_valves(path, min, releasing)
      opening = true
      path.each_with_index do |v, i|
        current_pressure = releasing_pressure
        min += 1
        break if min == 30
        releasing[min] = current_pressure
        print_move(min, v, current_pressure, opening)
        if v.open == false && v.flow_rate > 0 
          if opening
            v.open = true
            min += 1
            releasing[min] = current_pressure
            print_open(min, v, current_pressure, opening)
            break if min == 30
          end
          opening = !v.open
        else
          opening = !v.open
        end
      end

      min
    end

    def print_open(min, v, releasing, opening)
      puts "== min #{min} =="
      puts "open: #{opened_valves} releasing #{releasing} pressure"
      puts "open #{v.name}"
    end

    def print_move(min, v, releasing, opening)
      puts "== min #{min} =="
      puts "open: #{opened_valves} releasing #{releasing} pressure"
      puts "move to #{v.name}"
    end

    def closed?
      !valves.values.find { |v| v.open == false && v.flow_rate > 0 }.nil?
    end

    def close_all
      valves.values.each { |v| v.open = false }
    end


    def opened_valves
      valves.values.select { |v| v.open }.map { |v| v.name }
    end

    def releasing_pressure
      valves.values.select { |v| v.open }.map { |v| v.flow_rate }.sum
    end

    private

    def list(data)
      data.map { |v| v.name }.join(",")
    end

  end

  class Day16
    def self.run(argv)
      o = ProboscideaVolcanium.from(argv[0])

      o.path("OK")
     
    end
  end
end
