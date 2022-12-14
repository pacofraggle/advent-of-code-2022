def execute(day)
  return unless File.exist?("day#{day}.rb")

  puts "Day #{day} ---------------------------------"
  require_relative "day#{day}"

  klass = Module.const_get("Advent2022::Day#{day}")

  opts = ARGV.size <= 1 ? ["input-day#{day}"] : ARGV[1..-1]

  klass.run(opts)
end

if ARGV.size == 0
  (1..25).each { |i| execute(i.to_s.rjust(2, "0")) }
else
  execute(ARGV[0])
end
