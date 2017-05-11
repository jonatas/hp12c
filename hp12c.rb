class HP12C
  OPERATORS = /^([\+\/\*\-])$/

  attr_reader :mem, :x, :y, :z
  def initialize
    @x, @y, @z = 0.0,0.0,0.0
    @mem = {}
  end

  def eval string
    string.lines.each do |line|
      input = line.chomp
      compute(input)
    end
  end

  def compute input
    case input
    when OPERATORS then
      @y, @z = @x, @y
      operator = $1.to_sym
      @x = [@z, @y].inject operator
    when /^sto (.*)/ then
      @mem[$1] = @x
    when /^rcl (.*)/ then
      @x,@y,@z = @mem[$1],@x,@y
    else
      @x,@y,@z = input.to_f,@x,@y
    end
  end
end


if ARGV.index("--repl")
  calc = HP12C.new
  input = ""
  while input = gets
    calc.eval(input)
    puts calc.x if input =~ HP12C::OPERATORS
  end
end
