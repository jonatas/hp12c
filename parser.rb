class HP12C
  def initialize
    @x, @y, @z = 0.0,0.0,0.0
  end
  def eval string
    string.lines.each do |line|
      print "\nbefore: #{line.inspect}: #{xyz.inspect}\n" if $debug
      compute(line.chomp)
      puts " after:  #{" " * line.inspect.size} #{xyz.inspect}" if $debug
    end
  end

  def compute input
    case input
    when /^([\+\-\/\*])/ then
      @y, @z = @x, @y
      @x = @y.send($1.to_sym,@z)
    else
      @x,@y,@z = input.to_f,@x,@y
    end
  end

  def xyz
    [@x,@y,@z]
  end
end

class String
  def ok
    calc = HP12C.new
    $x, $y, $z = "","",""
    result = calc.eval(self)
    $x, $y, $z = calc.xyz
    result
  end
  def ok_if cond
    ok
    if cond.()
      print "."
    else
      file, line, _ = caller[0].split(":")
      lines = File.readlines(file)
      line_spec = line.to_i
      expression = []
      lines[0,line_spec].reverse.each_with_index do |line, line_index|
        expression.insert 0, line
        break if line =~ /^%\|/
      end

      what_failed = lines[line_spec-1].split(" -> {").last[0..-3]
      evaluated = what_failed.gsub(/\$\w+/){|r|eval(r).inspect}
      puts "fail on #{file}:#{line}     "+
           " #{what_failed}\n"+
           "        got #{evaluated}"
      puts "----------"
      puts expression
      puts "----------"
    end
  end
end

%||.ok_if -> { $x == 0 && $y == 0 && $z == 0 }

%|
1
|.ok_if -> { $x == 1 && $y == 0 }

%|
1

|.ok_if -> { $x == 0 && $y == 1 }

%|
1


|.ok_if -> { $x == 0 && $y == 0 &&  $z == 1 }

# curious? use $debug = true
%|
1
2
+
|.ok_if -> { $x == 3 }

