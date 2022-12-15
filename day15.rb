require 'set'

module Advent2022
  Point = Struct.new(:x, :y) do
    def d(other)
      (self.x - other.x).abs + (self.y - other.y).abs
    end
  end

  class Sensor
      attr_reader :sensor, :beacon, :ball_radius

      def initialize(sensor, beacon)
        @sensor = sensor
        @beacon = beacon

        @ball_radius = @sensor.d(@beacon)
      end

      def in_ball?(point)
        @sensor.d(point) <= @ball_radius
      end
  end

  class BeaconExclusionZone
  
    attr_reader :sensors

    def initialize
      @sensors = []
      @min_x = 4294967295
      @max_x = -4294967295
    end

    def add(sensor, beacon)
      s = Sensor.new(sensor, beacon)
      @sensors << s
      keep_margins(s)
    end
 
    def self.from(data)
      data = File.read(data) if File.exist?(data)

      o = BeaconExclusionZone.new
      data.each_line do |line|
        l = line.strip
        words=l.split(/ /)
        coords = [2, 3, 8, 9].map do |w|
          words[w].split(/=/)[1].gsub(/,/,'').gsub(/:/,'').to_i
        end
        o.add(Point.new(coords[0], coords[1]), Point.new(coords[2], coords[3]))
      end

      o
    end

    def check_row(y)
      row = Range.new(@min_x, @max_x).map { |x| Point.new(x, y) }

      covered = Set.new
      sensors.each do |s|
        row.each do |p|
          covered << p if s.in_ball?(p)
        end
      end

      sensors.each do |s|
        covered.delete(s.beacon)
      end

      covered.size
    end

    private

    def keep_margins(s)
      left = s.sensor.x - s.ball_radius
      right = s.sensor.x + s.ball_radius

      @min_x = left if left < @min_x
      @max_x = right if right > @max_x
    end
  end

  class Day15
    def self.run(argv)
      o = BeaconExclusionZone.from(argv[0])

      puts o.check_row(2000000)
     
    end
  end
end
