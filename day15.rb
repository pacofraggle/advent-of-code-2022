require 'set'

module Advent2022
  class Block
    attr_reader :data

    def initialize(min, max)
      @width = max - min + 1
      @data = []
      @deleted = Set.new

      @min = min
      @max = max
    end

    def fill(range)
      @data << range

      @data = IntegerRange.merge_overlapping(@data)
    end

    def unset(pos)
      @deleted << pos
    end

    def full?
      @data.size == 1 && @deleted.size == 0 && @data.first.size == @width
    end

    def count
      n = 0
      @data.each { |intv| n += intv.size }

      n - @deleted.size
    end

    def uncovered
      (@min..@max).each do |pos| 
        i = @data.find { |intv| intv.include?(pos) } 
        return pos if i.nil?
      end

      nil
    end
  end

  class IntegerRange < Range
    def overlap?(other)
      self.include?(other.begin) || other.include?(self.begin) || self.end + 1 == other.begin || other.end + 1 == self.begin
    end

    def intersect(other)
      IntegerRange.new([self.begin, other.begin].max, [self.end, other.end].min)
    end

    def union(other)
      IntegerRange.new([self.begin, other.begin].min, [self.end, other.end].max)
    end

    def self.merge_overlapping(overlapping_ranges)
      overlapping_ranges.sort_by(&:begin).inject([]) do |ranges, range|
        last = ranges.last
        if !ranges.empty? && last.overlap?(range)
          ranges[0...-1] + [last.union(range)]
        else
          ranges + [range]
        end
      end
    end
  end

  Point = Struct.new(:x, :y) do
    def d(other)
      (self.x - other.x).abs + (self.y - other.y).abs
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
    end

    def in_ball?(point)
      @sensor.d(point) <= @ball_radius
    end

    def in_ball_coord?(x, y)
      dy = (@sensor.y - y).abs 
      return false if dy > @ball_radius

      dx = (@sensor.x - x).abs 
      return false if dx > @ball_radius

      dx + dy <= @ball_radius
    end

    def ball_fill_row!(row, y, range)
      dy = (@sensor.y - y).abs 
      return if dy > @ball_radius

      bx = @ball_radius - dy

      xminb = @sensor.x - bx
      return if xminb > range.end
      xmaxb = @sensor.x + bx
      return if xmaxb < range.begin

      ball_range = IntegerRange.new(xminb, xmaxb)
      check_range = ball_range.intersect(range)
      
      row.fill(check_range)
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

    def check_row(y, min=nil, max=nil)
      min_x = min.nil? ? @min_x : min
      max_x = max.nil? ? @max_x : max

      covered = row_room_for_beacons(y, min_x, max_x, true)
      covered.count
    end

    def row_room_for_beacons(y, min, max, remove_existing=true)
      covered = Block.new(min, max)
      range = IntegerRange.new(min, max)

      sensors.each do |s|
        s.ball_fill_row!(covered, y, range)
        break if covered.full?
      end
  
      if remove_existing
        sensors.each do |s|
          covered.unset(s.beacon.x) if s.beacon.y == y
        end
      end

      covered
    end

    def beacon_space(min, max)
      (min..max).each_with_index do |i, idx|
        #puts "idx #{idx}" if idx % 1000 == 0
        covered = row_room_for_beacons(i, min, max, false)
        if !covered.full?
          return Point.new(covered.uncovered, i)
        end
      end
    end

    def clock
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def elapsed(msg, starting)
      ending = clock
      puts "#{msg} elapsed: #{ending-starting} sec" 
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
      #o.sensors.each_with_index do |s, i|
      #  puts "#{i}: #{s.ball_radius}"
      #end

      starting = o.clock
      puts "Part 1: #{o.check_row(2000000)}"
      o.elapsed("Part 1", starting)

      starting = o.clock
      beacon = o.beacon_space(0, 4000000)
      puts "Part 2: #{beacon.tuning_freq}"
      o.elapsed("Part 2", starting)
    end
  end
end
