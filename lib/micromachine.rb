class MicroMachine
  # Raised when an invalid event is triggered.
  #
  #   machine = MicroMachine.new(:new)
  #
  #   machine.trigger?(:random)
  #   # => MicroMachine::InvalidEvent: MicroMachine::InvalidEvent
  #
  #   machine.trigger(:random)
  #   # => MicroMachine::InvalidEvent: MicroMachine::InvalidEvent
  #
  InvalidEvent = Class.new(NoMethodError)

  # Returns a hash with events as keys and the defined
  # transitions of the events as values.
  #
  #   machine = MicroMachine.new(:pending)
  #   machine.when(:confirm, pending: :confirmed)
  #   machine.when(:reset, confirmed: :pending)
  #
  #   machine.transitions_for
  #   # => {:confirm=>{:pending=>:confirmed}, :reset=>{:confirmed=>:pending}}
  #
  attr :transitions_for

  # Returns current state.
  #
  #   machine = MicroMachine.new(:pending)
  #   machine.when(:confirm, pending: :confirmed)
  #
  #   machine.state
  #   # => :pending
  #
  #   machine.trigger(:confirm)
  #
  #   machine.state
  #   # => :confirmed
  #
  attr :state

  # Creates a state machine with an +initial_state+.
  #
  #   machine = MicroMachine.new(:new)
  #   machine.state
  #   # => :new
  #
  def initialize initial_state
    @state = initial_state
    @transitions_for = Hash.new
    @callbacks = Hash.new { |hash, key| hash[key] = [] }
  end

  # Adds a callback to +state+. +block+ is executed when
  # +state+ is triggered.
  #
  #   machine = MicroMachine.new(:pending)
  #   machine.when(:confirm, pending: :confirmed)
  #   machine.when(:reset, confirmed: :pending)
  #
  #   machine.on(:pending)   { puts "Pending" }
  #   machine.on(:confirmed) { puts "Confirmed" }
  #
  #   machine.trigger(:confirm)
  #   # => Confirmed
  #
  #   machine.trigger(:reset)
  #   # => Pending
  #
  # Use the special +state+ <tt>:any</tt> to define a callback
  # on any transition.
  #
  #   machine = MicroMachine.new(:pending)
  #   machine.when(:confirm, pending: :confirmed)
  #   machine.when(:reset, confirmed: :pending)
  #
  #   machine.on(:any) { puts "Transitioned" }
  #
  #   machine.trigger(:confirm)
  #   # => Transitioned
  #
  #   machine.trigger(:reset)
  #   # => Transitioned
  #
  def on key, &block
    @callbacks[key] << block
  end

  # Adds possibles +transitions+ for +event+.
  #
  #   machine = MicroMachine.new(:pending)
  #   machine.when(:confirm, pending: :confirmed)
  #
  #   machine.transitions_for[:confirm]
  #   # => {:pending=>:confirmed}
  #
  #   machine.when(:reset, confirmed: :pending, ignored: :pending)
  #
  #   machine.transitions_for[:reset]
  #   # => {:confirmed=>:pending, :ignored=>:pending}
  #
  def when(event, transitions)
    transitions_for[event] = transitions
  end

  # Tries to trigger +event+. If the transition is possible,
  # it changes the state, executes the defined callbacks and
  # returns +true+. Otherwise, the state remains unchanged and
  # +false+ is returned.
  #
  #   machine = MicroMachine.new(:pending)
  #   machine.when(:confirm, pending: :confirmed)
  #   machine.when(:ignore, pending: :ignored)
  #   machine.when(:reset, confirmed: :pending, ignored: :pending)
  #
  #   machine.on(:pending)   { puts "Pending" }
  #   machine.on(:confirmed) { puts "Confirmed" }
  #
  #   machine.trigger(:reset)
  #   # => false
  #
  #   machine.trigger(:confirm) # prints "Confirmed"
  #   # => true
  #
  #   machine.trigger(:reset) # prints "Pending"
  #   # => true
  #
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
