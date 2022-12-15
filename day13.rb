module Advent2022
  class Packet
    UNKNOWN = 0
    RIGHT = -1
    WRONG = 1
    attr_reader :data

    def initialize(array)
      @data = array
    end

    def self.from_string(s)
      Packet.new(eval(s))
    end

    def list?
      data.is_a? Array
    end

    def to_s
      @data.to_s
    end

    def compare(other)
      #puts "Compare #{self} vs #{other}"
      llist = self.list?
      rlist = other.list?

      if !llist && !rlist
        res = if self.data == other.data
                UNKNOWN
              elsif self.data < other.data
                RIGHT 
              else
                WRONG
              end
      elsif llist && rlist
        i = 0
        comp = UNKNOWN
        self.data.each_with_index do |a, i|
          a = Packet.new(a)
          b_data = other.data[i]
          comp = if b_data.nil?
                   WRONG
                 else
                   b = Packet.new(b_data)
                   a.compare(b)
                 end
          break unless comp == UNKNOWN
        end
          res = comp == UNKNOWN && self.data.size < other.data.size ?  RIGHT : comp
      elsif llist && !rlist
        b = Packet.new([other.data])
        res = self.compare(b)

      elsif rlist && !llist
        a = Packet.new([self.data])
        res = a.compare(other)
      else
        raise 'Panic'
      end
      #puts "  #{self} vs #{other} = #{res}"
      
      res
    end

    def <=>(other)
      return nil unless other.is_a? Packet

      self.compare(other)
    end
  end

  class Pair
    attr_accessor :left, :right

    def to_s
      "left: #{left} - right: #{right}"
    end

    def compare
      left.compare(right)
    end
  end
  
  class DistressSignal
    attr_reader :pairs, :packets

    def initialize
      @pairs = []
      @packets = []
    end

    def add(pair)
      @packets << pair.left
      @packets << pair.right

      @pairs << pair
    end

    def add_packet(packet)
      @packets << packet
    end

    def pair(i)
      @pairs[i-1]
    end

    def compare_pairs
      pairs.map { |p| p.compare }
    end

    def right_pairs
      compare_pairs.each_with_index.map { |c, i| i+1 if c == Packet::RIGHT }.compact
    end

    def sum_of_right_pairs
      right_pairs.reduce(:+)
    end

    def find_index_of(packet)
      @packets.each_with_index do |p, i| 
        return i+1 if p == packet
      end

      nil
    end

    def decoder(packet1, packet2)
      find_index_of(packet1)*find_index_of(packet2)
    end

    def self.from(data)
      data = File.read(data) if File.exist?(data)

      o = DistressSignal.new
      p = Pair.new
      data.each_line do |line|
        l = line.strip
        if l.empty?
          o.add(p)
          p = Pair.new
          next
        end
        if p.left.nil?
          p.left = Packet.from_string(l)
        else
          p.right = Packet.from_string(l)
        end
      end

      o.add(p) unless p.right.nil?

      o
    end
  end

  # Reading the file was easy-peasy due to Ruby's eval
  # First one about recursivity
  class Day13
    def self.run(argv)
      ds = DistressSignal.from(argv[0])
      puts "Part 1: #{ds.sum_of_right_pairs}"

      a = Packet.new([[2]])
      b = Packet.new([[6]])
      ds.add_packet(a)
      ds.add_packet(b)

      ds.packets.sort!

      puts "Part 2: #{ds.decoder(a, b)}"
    end
  end
end
