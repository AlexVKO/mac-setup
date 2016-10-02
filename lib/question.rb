require './lib/listener'

class Question
  def initialize question
    p "#{question} (Y/n)", :yellow
  end

  def ask
    answer = gets.chomp
    if positive?(answer)
      emit(:yes)
    else
      emit(:no)
    end
  end

  def on(event, &block)
    listeners << Listener.new(self, event, &block)
    self
  end

  def listeners
    @listeners ||= []
  end

  def positive?(answer)
    ['yes', 'y', 'true', 't', true, 'yep', 'yah', 'sim'].include?(answer.downcase)
  end

  def emit(event, *args)
    listeners.each do |listener|
      method_name = "on_#{event}"
      listener.send(method_name, *args) if listener.respond_to?(method_name, true)
    end
  end

end

class QuestionListener
  def initialize(context, event, &block)
    @context = context
    @event = event
    @block = block
    @event_method = :"on_#{@event}"
  end
  def method_missing(method_name, *args)
    return super unless respond_to_missing?(method_name, false)
    @block.call(*args)
  end
  def respond_to_missing?(method_name, include_private)
    method_name == @event_method
  end
end
