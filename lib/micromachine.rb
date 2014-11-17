class MicroMachine
  InvalidEvent = Class.new(NoMethodError)
  InvalidState = Class.new(ArgumentError)

  attr :transitions_for
  attr :state

  def initialize initial_state
    @state = initial_state
    @transitions_for = Hash.new
    @callbacks = Hash.new { |hash, key| hash[key] = [] }
  end

  def on key, &block
    @callbacks[key] << block
  end

  def when(event, transitions)
    transitions_for[event] = flatten_transitions(transitions)
  end

  def trigger(event)
    if trigger?(event)
      @state = transitions_for[event][@state]
      callbacks = @callbacks[@state] + @callbacks[:any]
      callbacks.each { |callback| callback.call }
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

  private

  def flatten_transitions(transitions)
    f_trans = {}
    transitions.each do |src, dst|
      [*src].each { |s| f_trans[s] = dst }
    end
    f_trans
  end
end
