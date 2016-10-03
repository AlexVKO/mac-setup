class String
  def colorfy(color="\e[0m")
    color_code =
    case color
    when :red
      "\e[91m"
    when :green
      "\e[92m"
    when :yellow
      "\e[93m"
    when :blue
      "\e[94m"
    when :magenta
      "\e[95m"
    when :cyan
      "\e[96m"
    else
      "\e[0m"
    end

    color_code + self + "\e[0m"
  end
end

def p(string, color=nil)
  puts string.colorfy(color)
end
