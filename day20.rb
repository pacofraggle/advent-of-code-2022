module Advent2022
  class LinkedList
    class Node
      attr_accessor :next, :prev
      attr_reader :value

      def initialize(value)
        @value = value
        @next  = nil
        @prev = nil
      end

      def to_s
        @value
      end

      #def ==(other)
      #end
    end

    attr_reader :head, :tail

    def initialize
      @head = nil
      @tail = nil
    end

    def append(value)
      node = LinkedList::Node.new(value)
      if @tail && @head
        node.next = @head
        node.prev = @tail

        @head.prev = node
        @tail.next = node
      else
        node.next = node
        node.prev = node
        @head = node
      end
      @tail = node

      node
    end
    def move_node_after(origin, dest)
      return if dest.next.equal?(origin)

      before = origin.prev
      after = origin.next

      before.next = after
      after.prev = before

      new_after = dest.next
      dest.next = origin
      origin.prev = dest
      new_after.prev = origin
      origin.next = new_after
      
      if tail?(origin)
        @tail = before
      end
      if head?(origin)
        @head = after
      end

      if tail?(dest)
        @head = origin
      end
    end

    def move_node_before(origin, dest)
      return if dest.prev.equal?(origin)

      before = origin.prev
      after = origin.next

      before.next = after
      after.prev = before

      new_before = dest.prev
      dest.prev = origin
      origin.next = dest
      new_before.next = origin
      origin.prev = new_before

      if tail?(origin)
        @tail = before
      end
      if head?(origin)
        @head = after
      end

      if head?(dest)
        @tail = origin
      end
    end

    def to_a
      current = @head 
      seq = []
      loop do
        seq << current.value
        current = current.next

        break if current.equal?(@head)
      end

      seq
    end

    def tail?(node)
      node.equal?(@tail)
    end

    def head?(node)
      node.equal?(@head)
    end
  end

  class GrovePositioningSystem
    attr_reader :list, :initial_sequence

    def initialize
      @list = LinkedList.new
      @initial_sequence = []
      @pivot = 0
    end

    def add_number(n)
      node = @list.append(n)
      @initial_sequence << node

      node
    end

    def move(i)
      elm = @initial_sequence[i]

      dest = elm
      if elm.value > 0
        elm.value.times { dest = dest.next }
        @list.move_node_after(elm, dest)
      elsif elm.value < 0
        elm.value.abs.times { dest = dest.prev }
        @list.move_node_before(elm, dest)
      end

      elm
    end

    def pivot
      result = move(@pivot)
      @pivot += 1

      result.value
    end

    def sequence
      @list.to_a
    end

    def mix
      @initial_sequence.each do |_|
        pivot
      end
    end

    def find(value)
      current = @list.head 
      until current.value.equal?(value) do
        return nil if @list.tail?(current)
        current = current.next
      end

      current
    end

    def traverse(n, from)
      current = from
      n.times { current = current.next }

      current
    end

=begin
    def grove_coords2
      mix 
      res = @list.to_a
      i = 0
      while true do
        break if res[i] == 0
        i+=1
      end
      puts "0 found at #{i}"
      puts res.size
      puts res[(i+1000) % res.size]
      puts res[(i+2000) % res.size]
      puts res[(i+3000) % res.size]

      [res[(i+1000) % res.size], res[(i+2000) % res.size], res[(i+3000) % res.size]]
    end
=end

    def grove_coords
      mix
      node0 = find(0)

      first = traverse(1000, node0)
      second = traverse(1000, first)
      third = traverse(1000, second)
      
      [first.value, second.value, third.value]
    end

    def self.from(data)
      data = File.read(data) if File.exist?(data)

      o = GrovePositioningSystem.new
      data.each_line do |line|
        l = line.strip
        o.add_number(l.to_i)
      end

      o
    end
  end

  class Day20
    def self.run(argv)
      o = GrovePositioningSystem.from(argv[0])
     
      coords = o.grove_coords
      puts coords.to_s
      puts "Part 1: #{coords.sum}"
    end
  end
end
