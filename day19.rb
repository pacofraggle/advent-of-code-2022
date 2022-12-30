require 'set'
require 'pry'

module Advent2022
  ORE = 0
  CLAY = 1
  OBSIDIAN = 2
  GEODE = 3

  LABEL = {
    ore: ORE,
    clay: CLAY,
    obsidian: OBSIDIAN,
    geode: GEODE
  }.freeze

  OreRobot = Struct.new(:ore)
  ClayRobot = Struct.new(:ore)
  ObsidianRobot = Struct.new(:ore, :clay)
  GeodeRobot = Struct.new(:ore, :obsidian)

  BluePrint = Struct.new(:id, :ore_robot, :clay_robot, :obsidian_robot, :geode_robot) do
    def can_build_robot?(type:, stock:)
      if type == :geode
        stock[ORE] >= geode_robot.ore && stock[OBSIDIAN] >= geode_robot.obsidian
      elsif type == :obsidian
        stock[ORE] >= obsidian_robot.ore && stock[CLAY] >= obsidian_robot.clay
      elsif type == :clay
        stock[ORE] >= clay_robot.ore
      elsif type == :ore
        stock[ORE] >= ore_robot.ore
      else
        raise 'Panic'
      end
    end

    def can_build(stock:)
      afford = []
      [:ore, :clay, :obsidian, :geode].each do |robot|
        afford << robot if can_build_robot?(type: robot, stock: stock)
      end

      afford
    end

    def build_robot(type:, stock:)
      return false unless can_build_robot?(type: type, stock: stock)

      if type == :geode
        stock[ORE] -= geode_robot.ore
        stock[OBSIDIAN] -= geode_robot.obsidian
      elsif type == :obsidian
        stock[ORE] -= obsidian_robot.ore
        stock[CLAY] -= obsidian_robot.clay
      elsif type == :clay
        stock[ORE] -= clay_robot.ore
      elsif type == :ore
        stock[ORE] -= ore_robot.ore
      else
        raise 'Panic'
      end

      true
    end

    # Main trimming happens here
    def should_build(stock:, robots:)
      affordable = can_build(stock: stock)

      # Geode beats them all
      return [:geode] if affordable.include?(:geode)

      # Prefer obsidian to anything lower
      if affordable.include?(:obsidian)
        # Avoid extras
        if robots[OBSIDIAN] >= geode_robot.obsidian
          affordable.delete(:obsidian)
        else
          return [:obsidian]
        end
      end

      # Avoid extras
      affordable.delete(:ore) if affordable.include?(:ore) && robots[ORE] >= [clay_robot.ore, obsidian_robot.ore, geode_robot.ore].max
      affordable.delete(:clay) if affordable.include?(:clay) && robots[CLAY] >= obsidian_robot.clay

      affordable
    end
  end
    
  class GeodesCollector
    attr_reader :stock, :robots, :t

    def initialize(blueprint, maxt=24, t=0, stock=nil, robots=nil)
      @blueprint = blueprint

      @stock = stock ? stock : [ 0, 0, 0, 0 ]
      @robots = robots ? robots : [ 1, 0, 0, 0 ]
 
      @t = t
      @maxt = maxt
    end

    def alternatives
      return [] if finished?

      alternatives = []

      buildable_robots = @blueprint.should_build(stock: @stock, robots: @robots)

      # Add the don't build option onlly when none of the two main robots can be built
      unless buildable_robots.include?(:geode) || buildable_robots.include?(:obsidian)
        sts = @stock.clone
        rbs = @robots.clone
        (0..3).each { |mineral| sts[mineral] += @robots[mineral] }

        alternatives << GeodesCollector.new(@blueprint, @maxt, @t+1, sts, rbs)
      end

      # Build
      buildable_robots.each do |robot|
        sts = @stock.clone
        rbs = @robots.clone
        @blueprint.build_robot(type: robot, stock: sts)
        (0..3).each { |mineral| sts[mineral] += @robots[mineral] }
        rbs[LABEL[robot]] += 1
          
        alternatives << GeodesCollector.new(@blueprint, @maxt, @t+1, sts, rbs)
      end

      alternatives
    end

    def finished?
      @t == @maxt
    end

    def value
      @stock[GEODE]
    end

    def to_s
      "#{t}: #{stock} | #{robots}"
    end
  end
    
  class NotEnoughMinerals
    attr_reader :blueprints

    def initialize
      @blueprints = {}
    end

    def add_blueprint(id, ore_r, clay_r, obsidian_r, geode_r)
      bp = BluePrint.new(id, ore_r, clay_r, obsidian_r, geode_r)
      @blueprints[id] = bp

      bp
    end

    def collector(bid, maxt=24)
      GeodesCollector.new(blueprints[bid], maxt)
    end

    def self.from(data)
      data = File.read(data) if File.exist?(data)

      o = NotEnoughMinerals.new
      data.each_line do |line|
        l = line.strip
        words = l.split(/ /)
        ore_r = OreRobot.new(words[6].to_i)
        clay_r = ClayRobot.new(words[12].to_i)
        obsidian_r = ObsidianRobot.new(words[18].to_i, words[21].to_i)
        geode_r = GeodeRobot.new(words[27].to_i, words[30].to_i)

        o.add_blueprint(words[1].gsub(/:/, "").to_i, ore_r, clay_r, obsidian_r, geode_r)
      end

      o
    end

    def register_max(collector)
      if collector.value > @max
        @max_collector = [] if collector.value > @max
        @max_collector << collector

        @max = collector.value
      end
    end

    def find_max(bp_id, maxt)
      starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      @max = -1
      @max_collector = []
      
      s = []
      discovered = Set.new

      s << collector(bp_id, maxt)

      until s.empty? do
        v = s.pop        

        prev = discovered.add?(v.to_s)
        if v.finished?
          register_max(v)
          next
        end

        next if prev.nil?
        v.alternatives.each do |w|
          if w.finished?
            register_max(w)
            discovered.add?(w.to_s)
          else
            s.push w 
          end
        end
      end

      ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      #puts "#{bp_id} (#{maxt}): #{@max} => #{@max_collector.map { |c| c.to_s }.join(", ")} // #{ending-starting} sec."
      @max
    end

    def quality_levels
      total = 0
      @blueprints.keys.each do |id|
        total += id * find_max(id, 24)
      end

      total
    end
  end

  # TODO: Approach this with Integer Linear Programming or Dynamic programming (Knapsack problem - storing sequences and comparing) 
  #
  # I tried again DFS aiming to trim the process ASAP
  # However I never got a valid trimming function. I tried to record the geode_robot_t of solutions
  # and trim worse cases but it discarded solutions (for bp 10 I got max 7 instead of 8)
  # Then I stuck to DFS, but tried to avoid candidates for the alternative paths because it took too long
  # I applied the rules I feel that make sense in general. I bet than depending on the input file some
  # could be valid and others not.
  # TODO: Indeed, the heuristics break one of the tests for 32
  #
  # Explore this heuristics I have just found in the reddit thread:
  # - Estimate the maximum amount of geode by assuming that we can build a geode robot at each time step.
  #   If that estimation is less or equal than the currently known maximal amount of geode, we do not have further investigate that branch.
  # - If we choose to wait (and not build a robot, but could have built it), do not build that robot in the next turn either.
  # - Do not build more robots than needed to build another robot, e.g. if the most expensive robot costs 5 ore, do not build more than 5 ore robots.
  # - Always build a geode robot if you can and do not investigate other branches in that case.
  class Day19
    def self.run(argv)
      o = NotEnoughMinerals.from(argv[0])

      puts "Part 1: #{o.quality_levels}"

      bp1 = o.find_max(1, 32)
      bp2 = o.find_max(2, 32)
      bp3 = o.find_max(3, 32)

      puts "Part 2: #{bp1}x#{bp2}x#{bp3} = #{bp1*bp2*bp3}"
    end
  end
end
