class Listener
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
