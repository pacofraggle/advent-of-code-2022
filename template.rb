module Advent2022
  class Name
  
    def initialize

    end

    def self.from(data)
      data = File.read(data) if File.exist?(data)

      o = Name.new
      data.each_line do |line|
        l = line.strip

      end

      o
    end
  end

  class Day14
    def self.run(argv)
      o = Name.from(argv[0])
     
    end
  end
end
