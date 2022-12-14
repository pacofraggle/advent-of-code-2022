module Advent2022
  class CargoCrates
    class Move
      attr_reader :amount, :from, :to
      def initialize(amount, from, to)
        @amount = amount
        @from = from
        @to = to
      end

      def to_s
        "move #{amount} from #{from} to #{to}"
      end

      def ==(other)
        amount == other.amount && from == other.from && to == other.to
      end
    end

    class Stack
      def initialize
        @crates = []
      end

      def stack(crate)
        @crates.push(crate)
      end

      def unstack
        @crates.pop
      end

      def last
        @crates.size > 0 ? @crates[-1] : " "
      end

      def to_s
        @crates.join
      end
    end

    def initialize(stacks, moves)
      @setup = stacks
      @moves = moves
    end

    def self.from_file(name)
      CargoCrates.new(
        CargoCrates.read_setup(name),
        CargoCrates.read_moves(name)
      )
    end

    def run(steps = -1)
      steps = @moves.size if steps == -1

      @moves.each_with_index do |move, i|
        break if i > steps-1

        (1..(move.amount)).each do |a|
          crate = @setup[move.from-1].unstack
          @setup[move.to-1].stack(crate)
        end
      end
    end

    def run_9001(steps = -1)
      steps = @moves.size if steps == -1

      @moves.each_with_index do |move, i|
        break if i > steps-1

        temp = Stack.new
        (1..(move.amount)).each do |a|
          crate = @setup[move.from-1].unstack
          temp.stack(crate)
        end
        while crate = temp.unstack do
          @setup[move.to-1].stack(crate)
        end
      end
    end


    def status
      @setup.map { |s| s.to_s }
    end

    def top_crates
      @setup.map { |s| s.last }.join
    end

    def self.read_setup(name)
      stacks = []
      data = []
      File.readlines(name).each do |line|
        break if line.strip == ''
        data << line.rstrip.chars
      end

      data[data.size-1].each_with_index do |v, i|
        next if v == ' '

        id = v.to_i - 1
        s = Stack.new
        (data.size-2).downto(0) do |line|
          crate = data[line][i]
          s.stack(crate) unless crate.nil? || crate == ' '
        end
        stacks[id] = s
      end

      stacks 
    end

    def self.read_moves(name)
      File.readlines(name).map do |line|
        next unless line.strip.start_with?("move ")
        words = line.strip.split(/ /)
        Move.new(words[1].to_i, words[3].to_i, words[5].to_i)
      end.compact
    end
  end

  class Day05
    def self.run(argv)
      cargo = CargoCrates.from_file(argv[0])
      cargo.run

#      puts cargo.status
#      puts
      puts cargo.top_crates

      cargo2 = CargoCrates.from_file(argv[0])
      cargo2.run_9001

#      puts cargo2.status
#      puts
      puts cargo2.top_crates
    end
  end
end
