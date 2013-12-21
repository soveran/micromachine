class MicroMachine
  InvalidEvent = Class.new(NoMethodError)

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
    transitions_for[event] = transitions
  end

  def trigger event
    if trigger?(event)
      @state = transitions_for[event][@state]
      callbacks = @callbacks[@state] + @callbacks[:any]
      callbacks.each { |callback| callback.call }
      true
    else
      false
    end
  end

  # Returns +true+ if +event+ triggers a change in state.
  #
  #   machine = MicroMachine.new(:pending)
  #   machine.when(:confirm, pending: :confirmed)
  #   machine.when(:ignore, pending: :ignored)
  #   machine.when(:reset, confirmed: :pending, ignored: :pending)
  #
  #   machine.state
  #   # => :pending
  #
  #   machine.trigger?(:reset)
  #   # => false
  #
  #   machine.trigger?(:confirm)
  #   # => true
  #
  #   machine.trigger?(:ignore)
  #   # => true
  #
  # Raises a <tt>MicroMachine::InvalidEvent</tt> error if an
  # invalid event is asked.
  #
  #   machine.trigger?(:invalid_event)
  #   # => MicroMachine::InvalidEvent: MicroMachine::InvalidEvent
  #
  def trigger?(event)
    raise InvalidEvent unless transitions_for.has_key?(event)
    transitions_for[event][state] ? true : false
  end

  # Returns an array with the defined events.
  #
  #   machine = MicroMachine.new(:pending)
  #
  #   machine.events
  #   # => []
  #
  #   machine.when(:confirm, pending: :confirmed)
  #   machine.when(:ignore, pending: :ignored)
  #   machine.when(:reset, confirmed: :pending, ignored: :pending)
  #
  #   machine.events
  #   # => [:confirm, :ignore, :reset]
  #
  def events
    transitions_for.keys
  end

  # Returns an array with the defined states.
  #
  #   machine = MicroMachine.new(:pending)
  #
  #   machine.states
  #   # => []
  #
  #   machine.when(:confirm, pending: :confirmed)
  #   machine.when(:ignore, pending: :ignored)
  #   machine.when(:reset, confirmed: :pending, ignored: :pending)
  #
  #   machine.states
  #   # => [:pending, :confirmed, :ignored]
  #
  def states
    events.map { |e| transitions_for[e].to_a }.flatten.uniq
  end

  # Returns +true+ if +some_state+ is equal to current state.
  # Otherwise, returns +false+.
  #
  #   machine = MicroMachine.new(:new)
  #
  #   machine == :pending
  #   # => false
  #
  #   machine == :new
  #   # => true
  #
  def ==(some_state)
    state == some_state
  end
end
