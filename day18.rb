require 'set'
require 'pry'

module Advent2022
  Cube = Struct.new(:xmin, :ymin, :zmin) do
    def overlap?(other)
      lx = (self.xmin - other.xmin).abs
      return false if lx > 1
      ly = (self.ymin - other.ymin).abs
      return false if ly > 1
      lz = (self.zmin - other.zmin).abs
      return false if lz > 1

      (lx == 1 && ly == 0 && lz == 0) ||
      (ly == 1 && lx == 0 && lz == 0) ||
      (lz == 1 && lx == 0 && ly == 0)
    end

    def to_s
      "(#{xmin}, #{ymin}, #{zmin})"
    end
  end

  class BoilingBoulders
  
    attr_reader :cubes

    def initialize
      @cubes = []
    end

    def add_cube(x, y, z)
      c = Cube.new(x, y, z)
      @cubes << c

      c
    end

    def self.from(data)
      data = File.read(data) if File.exist?(data)

      o = BoilingBoulders.new

      data.each_line do |line|
        l = line.strip
        x, y, z = l.split(/,/)
        o.add_cube(x.to_i, y.to_i, z.to_i)
      end

      o
    end

    def surface_area
      surface_area_for(@cubes)
    end

    def exterior_surface_area
      isolated = flood_fill

      surface_area_for(@cubes + isolated)
    end

    def flood_fill
      zmin, zmax = minmax(@cubes, :zmin)
      xmin, xmax = minmax(@cubes, :xmin)
      ymin, ymax = minmax(@cubes, :ymin)

      box = []
      (xmin-1).upto(xmax+1) do |x|
        (ymin-1).upto(ymax+1) do |y|
          (zmin-1).upto(zmax+1) do |z|
            cube = Cube.new(x, y, z)
            box << cube unless @cubes.include?(cube)
          end
        end
      end

      q = []
      q << box.first
      while !q.empty? do
        n = q.shift
        box.delete(n)
        neighbours = []
        neighbours << Cube.new(n.xmin-1, n.ymin, n.zmin) if n.xmin >= xmin
        neighbours << Cube.new(n.xmin+1, n.ymin, n.zmin) if n.xmin <= xmax
        neighbours << Cube.new(n.xmin, n.ymin-1, n.zmin) if n.ymin >= ymin
        neighbours << Cube.new(n.xmin, n.ymin+1, n.zmin) if n.ymin <= ymax
        neighbours << Cube.new(n.xmin, n.ymin, n.zmin-1) if n.zmin >= zmin
        neighbours << Cube.new(n.xmin, n.ymin, n.zmin+1) if n.zmin <= zmax
        neighbours.each do |neigh|
          q << neigh unless q.include?(neigh) || @cubes.include?(neigh) || !box.include?(neigh)
        end

      end

      box 
    end

    private

    def minmax(cubes, field)
      field_values = cubes.map { |cube| cube.send(field) }

      return field_values.min, field_values.max
    end

    def surface_area_for(cubes)
      overlaps = Array.new(cubes.size, 0)
      0.upto(cubes.size-2) do |i|
        cube = cubes[i]
        (i+1).upto(cubes.size-1) do |j|
          other = cubes[j]
          if cube.overlap?(other) 
            overlaps[i] += 1
            overlaps[j] += 1
          end
        end
      end
      cubes.size*6 - overlaps.sum
    end
  end

  # For part 2 I tried to fill from the inside, but there seems to be points that are not part of the figure
  # so it doesn't work. (plot with gnuplot or others)
  # I did flood fill. TODO: This needs optimization either of flood fill, of the used structures or using Dijkstra or
  # similar
  # Flood fill lets me find out the non-reachable areas. They I fill them to avoid counting the sides
  class Day18
    def self.run(argv)
      o = BoilingBoulders.from(argv[0])

      puts "Part 1: #{o.surface_area}"

      starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      puts "Part 2: #{o.exterior_surface_area}"
      ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      puts "  Elapsed for 2: #{ending-starting} sec"
    end
  end
end
