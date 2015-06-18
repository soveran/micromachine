class MicroMachine
  InvalidEvent = Class.new(NoMethodError)
  InvalidState = Class.new(ArgumentError)

  attr :transitions_for
  attr :state

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
    if trigger?(event)
      old_state, @state = @state, transitions_for[event][@state]
      callbacks = @callbacks[@state] + @callbacks[:any]
      callbacks.each { |callback|
        case callback.arity
        when 0
          callback.call
        when 1
          callback.call(event)
        when 2
          callback.call(event, old_state)
        else
          callback.call(event, old_state, @state)
        end
      }
      true
    else
      false
    end
  end

  def trigger!(event)
    if trigger(event)
      true
    else
      raise InvalidState.new("Event '#{event}' not valid from state '#{@state}'")
    end
  end

  def trigger?(event)
    raise InvalidEvent unless transitions_for.has_key?(event)
    transitions_for[event][state] ? true : false
  end

  def events
    transitions_for.keys
  end

  def states
    events.map { |e| transitions_for[e].to_a }.flatten.uniq
  end

  def ==(some_state)
    state == some_state
  end
end
