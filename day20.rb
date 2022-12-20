module Advent2022

  class GrovePositioningSystem
    attr_reader :list, :initial_sequence

    DECRYPTION_KEY = 811589153

    def initialize
      @list = []
      @initial_sequence = []
      @pivot = 0
      @append = true
    end

    def add_number(n)
      @initial_sequence << @list.size
      @list << n
    end

    def set_unshift
      @append = false
    end

    def find_pivot(i)
      @initial_sequence.each_with_index do |order, pos_i|
        if order == i
          return pos_i
        end
      end

      -1
    end

    def move(i)
      index = find_pivot(i)

      value = @list[index]
      return value if value == 0

      order = @initial_sequence[index]
      move_to = (index + value) % (@list.size-1)
      return value if move_to == index

      order = @initial_sequence.delete_at(index)
      value = @list.delete_at(index)

      if move_to == 0
        if @append
          @initial_sequence << order
          @list << value
        else
          @initial_sequence.unshift(order)
          @list.unshift(value)
        end
      else
        @initial_sequence.insert(move_to, order)
        @list.insert(move_to, value)
      end

      value
    end

    def pivot
      result = move(@pivot)
      @pivot += 1

      result
    end

    def sequence
      @list
    end

    def mix
      @pivot = 0
      @initial_sequence.each do |_|
        pivot
      end
    end

    def find(value)
      @list.each_with_index do |v, i|
        return i if v == value
      end

      nil
    end

    def grove_coords
      i = find(0)
      size = sequence.size

      [sequence[(i+1000) % size], sequence[(i+2000) % size], sequence[(i+3000) % size]]
    end

    def apply_key
      0.upto(@list.size-1) do |i|
        @list[i] *= DECRYPTION_KEY
      end
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

  # The linked list solution would have not escaled for part 2. I still don't understand why it doesn't work
  # (that code is in the previous commit)
  # set_unshift was an attempt to make test_rounds work
  # IT IS NOT NECESSARY because grove_coords IS RELATIVE to the position of 0
  # The test should be fixable by rotating everything so that 0 is at position 0
  #
  # It was hard for me to realize that the shift worked without left/right tricks if you removed the element first
  class Day20
    def self.run(argv)
      o = GrovePositioningSystem.from(argv[0])
     
      o.mix
      coords = o.grove_coords
      puts coords.to_s
      puts "Part 1: #{coords.sum}"

      o = GrovePositioningSystem.from(argv[0])
      #o.set_unshift
      o.apply_key
      10.times { o.mix }
      coords = o.grove_coords
      puts "Part 2: #{coords.sum}"
    end
  end
end
