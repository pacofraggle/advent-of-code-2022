module Advent2022
  class Monkey
    attr_reader :id, :items, :true, :false, :check
    attr_accessor :monkey_true, :monkey_false
    attr_reader :inspected

    def initialize
      @inspected = 0
    end

    def set_from(line)
      l = line.strip

      if l.start_with?("Monkey ")
        @id = l.split(/ /)[1].gsub(/:/, '').to_i
      elsif l.start_with?("Starting")
        @items = l.split(/: /)[1].split(/, /).map { |it| it.to_i }
      elsif l.start_with?("Operation")
        @op = l.split(/ /)[-2]
        @op_value = l.split(/ /)[-1]
      elsif l.start_with?("Test")
        @check = l.split(/ /)[-1].to_i
      elsif l.start_with?("If true")
        @true = @dest = l.split(/ /)[-1].to_i
      elsif l.start_with?("If false")
        @false = @dest = l.split(/ /)[-1].to_i
      else
        return false
      end

      true
    end

    def play
      @items.each do |w|
        exec = relief(execute_operation(w)) 

        if divisible?(exec)
          monkey_true.receive(exec)
        else
          monkey_false.receive(exec)
        end

        @inspected += 1
      end

      @items = []
    end

    def relief(value)
      value / 3
    end

    def execute_operation(value)
      operand = @op_value == "old" ? value : @op_value.to_i
      if @op == "+"
        value + operand
      elsif @op == "*"
        value * operand
      else
        raise "Panic"
      end
    end

    def divisible?(a)
      #div = a / @check
      #div*@check == a 

      return a % @check == 0
    end

    def receive(w)
      @items << w
    end

    def to_s
      "Monkey #{@id} [#{@items} | #{@op}, #{@op_value}, #{@check} | #{@monkey_true.id}, #{@monkey_false.id}]"
    end

  end

  class FastMonkey < Monkey
    def relief(value)
      value
    end

    def execute_operation(value)
      super(value) % @max
    end

    def set_max(max)
      @max = max
    end
  end


  class MonkeyBusiness

    attr_reader :monkeys

    def initialize
      @monkeys = []
    end

    def self.from_setup(setup, fast=false)
      setup = File.read(setup) if File.exist?(setup)

      mb = MonkeyBusiness.new

      monkey_class = fast ? FastMonkey : Monkey

      m = monkey_class.new
      setup.each_line do |line|
        ok = m.set_from(line)
        unless ok
          mb.add_monkey(m)
          m = monkey_class.new
        end
      end
      mb.add_monkey(m)
    
      divisibles = [1] if fast
      mb.monkeys.each do |m|
        m.monkey_true = mb.monkeys[m.true]
        m.monkey_false = mb.monkeys[m.false]
        divisibles << m.check if fast
      end

      if fast
        lcm = divisibles.reduce(1, :lcm)
        mb.monkeys.each { |m| m.set_max(lcm) }
      end

      mb
    end

    def add_monkey(monkey)
      @monkeys << monkey
    end

    def monkey_items
      monkeys.map { |m| m.items }
    end

    def monkey_inspections
      monkeys.map { |m| m.inspected }
    end

    def value
      monkey_inspections.max(2).reduce(:*)
    end

    def round
      @monkeys.each do |m|
        m.play
      end
    end

    def rounds(n)
      1.upto(n) do |i| 
        #puts "Round #{i}" if i % 50 == 0
        #starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        round
        #ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        #puts "  #{ending-starting} s"
      end
    end
  end

  # I spent a lot of time trying to speed up the divisions
  # All of them are divisions by prime numbers and found rules to optimize them
  # However numbers kept being very large. This was the key sentence:
  #
  # > you'll need to find another way to keep your worry levels manageable. 
  #
  # The exercise was all about the use of the remainder (see FastMonkey)
  class Day11
    def self.run(argv)
      mb = MonkeyBusiness.from_setup(argv[0], false)
      mb.rounds(20)
      puts "Part 1: #{mb.value}"

      mb = MonkeyBusiness.from_setup(argv[0], true)
      mb.rounds(10000)
      puts "Part 2: #{mb.value}"
    end
  end
end
