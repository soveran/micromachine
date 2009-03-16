# Finite State Machine
#
# Usage:
#
#   machine = MicroMachine.new(:new) # Initial state.
#
#   machine.transitions_for[:confirm] = { :new => :confirmed }
#   machine.transitions_for[:ignore]  = { :new => :ignored }
#   machine.transitions_for[:reset]   = { :confirmed => :new, :ignored => :new }
#
#   machine.trigger(:confirm)  #=> true
#   machine.trigger(:ignore)   #=> false
#   machine.trigger(:reset)    #=> true
#   machine.trigger(:ignore)   #=> true
#
# It also handles callbacks that are executed when entering a different state.
#
#   machine.on(:confirmed) do
#     puts "Confirmed"
#   end
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
