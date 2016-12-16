class MicroMachine
  InvalidEvent = Class.new(NoMethodError)
  InvalidState = Class.new(ArgumentError)

  attr_reader :transitions_for
  attr_reader :state

  def initialize(initial_state)
    @state = initial_state
    @transitions_for = Hash.new
    @callbacks = Hash.new { |hash, key| hash[key] = [] }
  end

  def on(key, &block)
    @callbacks[key] << block
  end

  def when(event, transitions)
    transitions_for[event] = transitions
  end

  def trigger(event)
    trigger?(event) and change(event)
  end

  def trigger!(event)
    trigger(event) or
      raise InvalidState.new("Event '#{event}' not valid from state '#{@state}'")
  end

  def trigger?(event)
    raise InvalidEvent unless transitions_for.has_key?(event)
    transitions_for[event].has_key?(state)
  end

  def events
    transitions_for.keys
  end

  def triggerable_events
    events.select { |event| trigger?(event) }
  end

  def states
    transitions_for.values.map(&:to_a).flatten.uniq
  end

private

  def change(event)
    @state = transitions_for[event][@state]
    callbacks = @callbacks[@state] + @callbacks[:any]
    callbacks.each { |callback| callback.call(event) }
    true
  end
end
