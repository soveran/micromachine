class MicroMachine
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

  def trigger event
    if transitions_for[event][@state]
      @state = transitions_for[event][@state]
      @callbacks[@state].each { |callback| callback.call }
      true
    end
  end
end
