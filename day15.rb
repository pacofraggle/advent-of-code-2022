require 'set'

module Advent2022
  Point = Struct.new(:x, :y) do
    def d(other)
      (self.x - other.x).abs + (self.y - other.y).abs
    end

    def coord_d(x, y)
      (self.x - x).abs + (self.y - y).abs
    end

    def tuning_freq
      self.x*4000000 + y
    end
  end

  class Sensor
    attr_reader :sensor, :beacon, :ball_radius

    def initialize(sensor, beacon)
      @sensor = sensor
      @beacon = beacon

      @ball_radius = @sensor.d(@beacon)
      @x = @sensor.x
      @y = @sensor.y
    end

    def in_ball?(point)
      @sensor.d(point) <= @ball_radius
    end

    def in_ball_coord?(x, y)
      #dy = (@y - y).abs 

      #bx = @ball_radius - dy
      #return false if bx < 0

      #return x >= @x - bx && x <= @x + bx

      dy = (@y - y).abs 
      return false if dy > @ball_radius

      dx = (@x - x).abs 
      return false if dx > @ball_radius

      dx + dy <= @ball_radius
    end

    def ball_fill_row!(row, y, xmin, xmax)
      dy = (@y - y).abs 

      return if dy > @ball_radius

      bx = @ball_radius - dy

      xminb = @x - bx
      return if xminb > xmax
      xmaxb = @x + bx
      return if xmaxb < xmin

      ini = xmin > xminb ? xmin : xminb
      fin = xmax > xmaxb ? xmaxb : xmax

      (ini..fin).each do |pos|
        row[pos-xmin] = true
      end
    end

    def box
      return Point.new(@sensor.x-@ball_radius, @sensor.y-@ball_radius), Point.new(@sensor.x+@ball_radius, @sensor.y+@ball_radius)
    end
  end

  class BeaconExclusionZone
  
    attr_reader :sensors

    def initialize
      @sensors = []
      @min_x = 4294967295
      @min_y = 4294967295
      @max_x = -4294967295
      @max_y = -4294967295
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

    def check_row(y, remove_beacons=true, min=nil, max=nil)
      min_x = min.nil? ? @min_x : min
      max_x = max.nil? ? @max_x : max

      covered = row_room_for_beacons(y, min_x, max_x, remove_beacons)
      covered.count(true)
    end

    def row_room_for_beacons(y, min, max, remove_existing=true)
      #puts "Row #{y}"
      row = Range.new(min, max)
      covered = Array.new(row.size, false)

      sensors.each do |s|
        s.ball_fill_row!(covered, y, min, max)
      end
  
#      row.each do |x|
#        sensors.each do |s|
#          if s.in_ball_coord?(x, y)
#            covered[x-min] = true
#          end
#        end
#      end

      if remove_existing
        sensors.each do |s|
          covered[s.beacon.x-min] = false if s.beacon.y == y
        end
      end

      covered
    end

    def beacon_space(min, max)
      width = max - min + 1
      (min..max).each do |y|
        covered = row_room_for_beacons(y, min, max, false)
        if covered.count(false) > 0
          covered.each_with_index do |val, col|
            return Point.new(col+min, y) unless val
          end
        end
      end
    end

    private

    def keep_margins(s)
      top = s.sensor.y - s.ball_radius
      left = s.sensor.x - s.ball_radius
      right = s.sensor.x + s.ball_radius
      down = s.sensor.y + s.ball_radius

      @min_x = left if left < @min_x
      @min_y = top if top < @min_y
      @max_x = right if right > @max_x
      @max_y = down if down > @max_y
    end
  end

  class Day15
    def self.run(argv)
      o = BeaconExclusionZone.from(argv[0])
      o.sensors.each_with_index do |s, i|
        puts "#{i}: #{s.ball_radius}"
      end
      

      starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      puts "Part 1: #{o.check_row(2000000)}"
      ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      puts "Elapsed: #{ending-starting} sec" 

      #starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      beacon = o.beacon_space(0, 4000000)
      puts "Part 2: #{beacon.tuning_freq}"
      #ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      #puts "Elapsed: #{ending-starting} sec" 
    end
  end
end
