class HP12C
  attr_reader :storage
  def initialize
    @x, @y, @z = 0.0,0.0,0.0
    @storage = {}
  end
  def eval string
    string.lines.each do |line|
      input = line.chomp
      compute(input)
      label = (input == "" ? "ENTER" : input).ljust(10)
      if $debug
        puts "#{label}: #{xyz.inspect.ljust(25)} #{@storage.inspect.ljust(15)}"
      elsif $repl
        print "#{label} => #@x\n"
      end
    end
  end

  def compute input
    case input
    when "-" then
      @y, @z = @x, @y
      @x = (@z - @y)
    when /^([\+\/\*])/ then
      @y, @z = @x, @y
      operator = $1.to_sym
      @x = [@z, @y].inject operator
    when /^sto (.*)/ then
      @storage[$1] = @x
    when /^rcl (.*)/ then
      @x,@y,@z = @storage[$1],@x,@y
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
    $mem = calc.storage
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
      lines[0,line_spec].reverse.each_with_index do |_line, line_index|
        expression.insert 0, _line
        break if _line =~ /^%\|/
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

%||.ok_if -> { $x == 0 && $y == 0 && $z == 0 && $mem == {} }

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
|.ok_if -> { $x == 3 && $y == 2 && $z == 1 }

%|
1
2
+
+
|.ok_if -> { $x == 5 && $y == 3 && $z == 2 }

%|
1
2
+
5
+
|.ok_if -> { $x == 8 }

%|
10
2
/
|.ok_if -> { $x == 5 }

## sto for storage

%|
10
sto 1
|.ok_if -> { $mem['1'] == 10.0 }

%|
10
sto 1
2
+
sto 2
|.ok_if -> { $mem['1'] == 10.0 && $mem['2'] == 12.0  }

%|
rcl 1
rcl 2
rcl 3
|.ok_if -> { [$x,$y,$z] == [nil,nil,nil] }

%|
1234
sto 1
rcl 1
|.ok_if -> { $x == 1234 }

%|
10
sto 1
20
sto 2
30
sto 3
rcl 1
rcl 2
rcl 3
|.ok_if -> { [$x,$y,$z].compact == [30,20,10] }

%|
123
sto 1
456
sto 2
rcl 2
rcl 1
-
|.ok_if -> { $x == 333 }

$debug = ARGV.index("--debug") || ARGV.index("-d")
$repl = ARGV.index("--repl")

%|
123
sto 1
456
sto 2
789
sto 3

rcl 3
rcl 2
+
rcl 1
+
sto 4
|.ok_if -> { $x == 1368 && $mem['4'] == 1368 }

