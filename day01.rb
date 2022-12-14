module Advent2022
  class CaloriesCounter

    def initialize
      @elf = []
    end

    def self.from_file(name)
      counter = CaloriesCounter.new

      File.readlines(name).each do |line|
        counter.add_calories_line(line)
      end

      counter
    end

    def add_calories_line(line)
      value = line.strip

      @elf << 0 if @elf.size == 0

      if value == ""
        @elf << 0
      else
        @elf[@elf.size-1] += value.to_i
      end
    end  

    def max
      @elf.max
    end

    def top3total
      @elf.max(3).inject(:+)
    end

    def calories
      @elf
    end
  end


  class Day01
    def self.run(argv)
      counter = CaloriesCounter.from_file(argv[0])

      puts counter.max
      puts counter.top3total
    end
  end
end
