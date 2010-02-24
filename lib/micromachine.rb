class MicroMachine
  InvalidEvent = Class.new(NoMethodError)

  attr :transitions_for
  attr :state

  def initialize initial_state
    @state = initial_state
    @transitions_for = Hash.new
    @callbacks = Hash.new { |hash, key| hash[key] = [] }
    @callbacks[:any] = []
  end

  def on key, &block
    @callbacks[key] << block
  end

  def trigger event
    if trigger?(event)
      @state = transitions_for[event][@state]
      @callbacks[@state].each { |callback| callback.call }
      @callbacks[:any].each { |callback| callback.call }
      true
    end
  end

  def trigger?(event)
    transitions_for[event][state]
  rescue NoMethodError
    raise InvalidEvent
  end
end
