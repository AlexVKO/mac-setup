require './lib/listener'

class Installation
  def initialize program_name
    @program_name = program_name
    p "installing #{program_name}", :yellow
  end

  def command(command)
    @command = command
    self
  end

  def install! opts={}
    if opts[:unless]
      p "🤘 🤘 🤘  #{@program_name} installed and configured 🤘 🤘 🤘", :green
      return if `which "#{opts[:unless_it_is_in_path]}"`
    end

    system @command
    if $?.success?
      emit(:success)
      p "🤘 🤘 🤘  #{@program_name} installed and configured 🤘 🤘 🤘", :green
    else
      emit(:fail)
      p "💩 💩 💩 #{@program_name} instalation failed 💩 💩 💩", :red
    end

  end

  def on(event, &block)
    listeners << Listener.new(self, event, &block)
    self
  end

  def listeners
    @listeners ||= []
  end

  def emit(event, *args)
    listeners.each do |listener|
      method_name = "on_#{event}"
      listener.send(method_name, *args) if listener.respond_to?(method_name, true)
    end
  end
end
