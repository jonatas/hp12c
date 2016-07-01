class HP12C
  attr_reader :x,:y,:z
  def initialize
    @x, @y, @z = *[""]*3
  end
  def eval string
    string.lines.each do |line|
      compute(line)
    end
  end
end

class String
  def ok
    calc = HP12C.new
    result = calc.eval(self)
    $x == calc.x
    $y == calc.y
    $z == calc.z
    result
  end
  def ok_if cond
    unless cond.()
      file, line, _ = caller[0].split(":")
      lines = File.readlines(file)
      line_spec = line.to_i
      expression = []
      lines[0..line_spec].reverse.each_with_index do |line, line_index|
        expression.insert 0, line
        break if line =~ /^%\|$/
      end

      puts "fail: #{line}: #{lines[line_spec]}"
      puts "----------"
      puts expression
      puts "----------"
    end
  end
end

%||.ok if $x == "" && $y == "" && $z == ""

%|
1
|.ok if $x == "" && $y == 1

%|
1
2
+
|.ok_if -> { $x == 3 }

