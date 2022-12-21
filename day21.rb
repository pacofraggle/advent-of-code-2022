module Advent2022
  class MonkeyYell
    attr_reader :value, :name, :operation, :depends

    def initialize(name, operation)
      @name = name
      parts = operation.split(/ /)
      if parts.size == 3
        @operation = "(#{operation})"
        @depends = [parts[0], parts[2]] # Warning: No initial cases with half result
      else
        @operation = operation
        @depends = nil
      end
      
      evaluate
    end

    def value?
      !@value.nil?
    end

    def replace(variable, value)
      val = value.to_s
      res = operation.gsub!(variable, val)

      return false if res.nil?

      depends.delete(variable)

      # This block is only needed for expand
      deps = val.tr("(", "").gsub(")", "").split(/ /)
      if deps.size == 3
        depends << deps[0] unless MonkeyYell.int(deps[0])
        depends << deps[2] unless MonkeyYell.int(deps[2])
      end

      true
    end
  
    def evaluate
      @value = MonkeyYell.int(operation)
    end

    def to_s
      value? ? "#{name}: #{operation}=#{value}" : "#{name}: #{operation}"
    end

    def self.int(value)
      eval value

    rescue StandardError
      nil
    end
  end

  class MonkeyMath
    INVERSES = {
      :+ => :-,
      :- => :+,
      :* => :/,
      :/ => :*
    }.freeze

    def initialize
      @solved = {}
      @unsolved = {}
    end

    def monkeys
      @solved.keys + @unsolved.keys
    end

    def add_monkey(name, operation)
      m = MonkeyYell.new(name, operation)

      if m.value?
        @solved[name] = m
      else
        @unsolved[name] = m
      end
          
      m
    end

    def self.from(data)
      data = File.read(data) if File.exist?(data)

      mm = MonkeyMath.new
      data.each_line do |line|
        l = line.strip
        parts = l.split(/: /)

        mm.add_monkey(parts[0], parts[1])
      end

      mm
    end

    def value(variable)
      while @solved[variable].nil? && !@unsolved.empty?
        solved = 0
        @unsolved.keys.each do |unknown|
          solved +=1 if flat_solve(unknown)
        end

        return nil if solved == 0
      end

      @solved[variable].value
    end

    def human_yell
      root = @unsolved.delete("root")
      human = @solved.delete("humn")
      left = root.depends[0]
      right = root.depends[1]

      side1 = value(left)
      side2 = value(right)

      if side1.nil? && !side2.nil?
        #expand(root.depends[0])
        #expr = @unsolved[root.depends[0]].operation
        var = left
        result = side2

      elsif side2.nil? && !side1.nil?
        #expand(root.depends[1])
        #expr = @unsolved[root.depends[1]].operation
        var = right
        result = side1
      else
        raise 'No clue!'
      end

      solve_eq(var, result)
    end

    private

    # true: did sth. false did nothing
    def flat_solve(variable)
      return false if @solved[variable]

      unknown = @unsolved[variable]

      return false unless unknown

      replacements = 0
      unknown.depends.each do |dep_var|
        d = @solved[dep_var]
        if d
          replaced = unknown.replace(dep_var, d.value)
          replacements += 1 if replaced
        end
      end
      if unknown.depends.empty?
        unknown.evaluate
        @unsolved.delete(unknown.name)
        @solved[variable] = unknown

        return true
      end

      replacements > 0
    end

    # This was meant to be used after value("root") to find the full expression
    def expand(variable)
      m = @unsolved[variable]
      expanding = true
      until m.depends.empty? || !expanding do
        v = m.depends[0]
        repl = @unsolved[v]
        next unless repl
        m.replace(v, repl.operation)

        expanding = m.depends != ["humn"]
      end
    end

    def solve_eq(var, result)
      humn = result
      while true do
        m = @unsolved[var]
        humn, var = operate(m.operation, humn)
        break if var == "humn"
      end

      humn
    end


    def operate(operation, result)
      parts = operation.tr("(", "").tr(")", "").split(/ /)

      raise 'Nonsense' if parts.size != 3

      op = parts[1].to_sym
      iop = INVERSES[op]

      raise "Don't know about this" if iop.nil?

      val = MonkeyYell.int(parts[0])
      if val.nil? # constant on the right
        next_var = parts[0]
        val = MonkeyYell.int(parts[2])
        transform = result.send(iop, val)
      else # constant on the left
        next_var = parts[2]
        transform = if op == :-
                      val - result
                    elsif op == :/
                      val / result
                    else
                      result.send(iop, val)
                    end
      end
        
      return transform, next_var
    end
  end

  # I feel this should have been solved with binary trees. TODO: review compilers notes
  #
  # Part two brings these two cases
  # L Side hsdb: (depends on humn)
  # R Side mwrd: 34588563455325
  # And unsolved stays like this:
  # cswp: (926 + qlcr), dplf: (dcmn + 331), dgjg: (5 * lpwp), rftv: (ssqw * 2), jdnp: (rwsm * 2), ssqw: (ffdd - 465), rwsm: (nvvt + 26), crzt: (jwnm - 398), bjqp: (421 + vljm), jzhq: (jcdd - 437), fnfl: (zgmz - 999), whfs: (bsrr - 264), dqsj: (cqrt - 763), cmmj: (cswp * 3), ggvm: (rsbw / 5), frgr: (htst - 516), bsrr: (ffjs / 2), svlj: (tgfp - 262), rntj: (jdnp - 650), wjmr: (194 + jfjz), trbf: (nvvv + 183), rsbw: (245 + lhzt), htst: (mnfl / 6), dcsf: (971 + zmnw), zmnw: (qmpd * 2), jcdd: (19 * dplf), tmts: (tpdr + 157), dhcj: (rbth / 6), jfjz: (vftz * 15), vljm: (3 * crzt), ffdd: (trbf * 18), jwnm: (fwfp / 2), lbjr: (whfs / 2), mnfl: (542 + humn), tpdr: (swcz - 897), dprj: (lbmr * 3), mrvc: (bjqp + 287), tgfp: (vhpc * 2), bpvq: (dgjg - 148), svsd: (drlh - 266), rbth: (180354410322238 - nzbf), nvzn: (svsd / 12), srrz: (jssr / 2), fwfp: (dprj - 965), hfnh: (476 + dhcj), swcz: (wjmr * 2), vhpc: (bqvb + 898), nzbf: (tmts / 2), drlh: (fqnp * 2), frsp: (81 + dqsj), bqvb: (frsp / 11), nvvt: (mrvc / 2), dwrc: (rftv + 388), qlcr: (fnfl / 2), jssr: (shpn - 660), lpwp: (nvzn + 684), lhzt: (2 * jzhq), lbmr: (24 + ggvm), nvvv: (svlj / 6), hsdb: (3 * hfnh), shpn: (rntj / 7), cqrt: (192 * frgr), zgmz: (dwrc / 2), dcmn: (bpvq / 11), fqnp: (26 + lbjr), vftz: (721 + srrz), qmpd: (cmmj - 387), ffjs: (561 + dcsf)
  # Which leads (using expand) to the following expression for hsdb:
  # (3 * (476 + ((180354410322238 - (((((194 + ((721 + (((((((((421 + (3 * (((((24 + ((245 + (2 * ((19 * ((((5 * (((((26 + ((((561 + (971 + ((((926 + ((((((((((((((81 + ((192 * (((542 + x) / 6) - 516)) - 763)) / 11) + 898) * 2) - 262) / 6) + 183) * 18) - 465) * 2) + 388) / 2) - 999) / 2)) * 3) - 387) * 2))) / 2) - 264) / 2)) * 2) - 266) / 12) + 684)) - 148) / 11) + 331)) - 437))) / 5)) * 3) - 965) / 2) - 398))) + 287) / 2) + 26) * 2) - 650) / 7) - 660) / 2)) * 15)) * 2) - 897) + 157) / 2)) / 6)))=34588563455325
  # Removing * with spaces Wolfram Alpha solves it (image in repo)
  # (3(476+((180354410322238-(((((194+((721+(((((((((421+(3(((((24+((245+(2((19((((5(((((26+((((561+(971+((((926+((((((((((((((81+((192(((542+x)/6)-516))-763))/11)+898)2)-262)/6)+183)18)-465)2)+388)/2)-999)/2))3)-387)2)))/2)-264)/2))2)-266)/12)+684))-148)/11)+331))-437)))/5))3)-965)/2)-398)))+287)/2)+26)2)-650)/7)-660)/2))15))2)-897)+157)/2))/6)))=34588563455325
  # And that made me realize that - and / are not commutative so just the inverse wasn't enough. (Z, +, x) is a ring.
  class Day21
    def self.run(argv)
      o = MonkeyMath.from(argv[0])
      puts "Part 1: #{o.value("root")}"

      o = MonkeyMath.from(argv[0])
      puts "Part 2: #{o.human_yell}"
    end
  end
end
