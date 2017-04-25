class HP12C
  attr_reader :mem, :x, :y, :z
  def initialize
    @x, @y, @z = 0.0,0.0,0.0
    @mem = {}
  end

  def eval string
    string.lines.each do |line|
      input = line.chomp
      compute(input)
      label = (input == "" ? "ENTER" : input).ljust(10)
      if $debug
        puts "#{label}: #{xyz.inspect.ljust(25)} #{@mem.inspect.ljust(15)}"
      elsif $repl
        print "#{label} => #@x\n"
      end
    end
  end

  def compute input
    case input
    when /^([\+\/\*\-])/ then
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
