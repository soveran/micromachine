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
    if block.arity > 3
      raise ArgumentError,
           "Callback for #{key} have #{block.arity} arguments, but only 3 allowed"
    end

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

  def states
    transitions_for.values.map(&:to_a).flatten.uniq
  end

private

  def change(event)
    previous_state, @state = @state, transitions_for[event][@state]

    all_arguments = [event, previous_state, state]

    callbacks = @callbacks[@state] + @callbacks[:any]
    callbacks.each do |callback|
      case callback.arity
      when -1
        callback.call(*all_arguments)
      when 0..3
        arguments = all_arguments.take(callback.arity)
        callback.call(*arguments)
      end
    end

    true
  end
end
