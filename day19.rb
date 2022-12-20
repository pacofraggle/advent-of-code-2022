module Advent2022
  OreRobot = Struct.new(:ore)
  ClayRobot = Struct.new(:ore)
  ObsidianRobot = Struct.new(:ore, :clay)
  GeodeRobot = Struct.new(:ore, :obsidian)

  BluePrint = Struct.new(:id, :ore_robot, :clay_robot, :obsidian_robot, :geode_robot) do
    def can_build_robot?(type:, stock:)
      if type == :geode
        stock[:ore] >= geode_robot.ore && stock[:obsidian] >= geode_robot.obsidian
      elsif type == :obsidian
        stock[:ore] >= obsidian_robot.ore && stock[:clay] >= obsidian_robot.clay
      elsif type == :clay
        stock[:ore] >= clay_robot.ore
      elsif type == :ore
        stock[:ore] >= ore_robot.ore
      else
        raise 'Panic'
      end
    end

    def build_robot(type:, stock:)
      return false unless can_build_robot?(type: type, stock: stock)

      if type == :geode
        stock[:ore] -= geode_robot.ore
        stock[:obsidian] -= geode_robot.obsidian
      elsif type == :obsidian
        stock[:ore] -= obsidian_robot.ore
        stock[:clay] -= obsidian_robot.clay
      elsif type == :clay
        stock[:ore] -= clay_robot.ore
      elsif type == :ore
        stock[:ore] -= ore_robot.ore
      else
        raise 'Panic'
      end

      true
    end

    def should_build?(stock, robots)
      return :geode if stock[:obsidian] + robots[:obsidian] >= geode_robot.obsidian

      return :obsidian if stock[:clay] + robots[:clay] > bsidian_robot.clay

      return :clay if robots[:clay] == 0 || stock[:ore] + robots[:ore] >= clay_robot.ore

      :ore
    end
  end
    
  

  class GeodesCollector
    attr_reader :stock, :robots, :minute

    def initialize(blueprint)
      @blueprint = blueprint
      @stock = {
        ore: 0,
        clay: 0,
        obsidian: 0,
        geode: 0
      }
      @robots = {
        ore: 1,
        clay: 0,
        obsidian: 0,
        geode: 0
      }
      @minute = 0
    end

    def execute
      @minute += 1

      # build
      mineral = @blueprint.should_build?(@stock, @robots)
      building = @blueprint.build_robot(type: mineral, stock: @stock)
      building_robot = building ? mineral : nil

      # collect
      @robots.keys.each do |mineral|
        @stock[mineral] += @robots[mineral]
      end

      # add new robot
      @robots[building_robot] += 1 if building_robot 
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

    def collector(bid)
      GeodesCollector.new(blueprints[bid])
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
  end

  class Day19
    def self.run(argv)
      o = NotEnoughMinerals.from(argv[0])
     
    end
  end
end
