class String
  def colorfy(color="\e[0m")
    color_code =
    case color
    when :red
      "\e[1;31;40m"
    when :green
      "\e[1;32;40m"
    when :yellow
      "\e[1;33;40m"
    when :blue
      "\e[1;34m"
    else
      "\e[0m"
    end

    color_code + self + "\e[0m"
  end
end

def p(string, color=nil)
  puts string.colorfy(color)
end