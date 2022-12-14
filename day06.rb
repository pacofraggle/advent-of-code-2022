module Advent2022
  class Tuning
    def initialize(buffer)
      @buffer = buffer
    end

    def marker(length = 4)
      i = length-1
      @buffer.chars[(length-1)..-1].find do |ch|
        block = @buffer[(i-length+1)..i]
        i += 1
        uniq?(block)
      end

      i
    end

    def self.find_marker(buffer, length = 4)
      Tuning.new(buffer).marker(length)
    end

    def self.find_marker_from_file(name, length = 4)
      f = File.open(name)
      buffer = f.read
      f.close

      Tuning.find_marker(buffer, length)
    end

    private

    def uniq?(str)
      str.chars.uniq.size == str.size
    end

  end

  class Day06
    def self.run(argv)
      puts "For 4: "+Tuning.find_marker_from_file(argv[0]).to_s
      puts "For 14: "+Tuning.find_marker_from_file(argv[0], 14).to_s
    end
  end
end
