# Finite State Machine
#
# Usage:
#
#   fsm = MicroMachine.new(:new) # Initial state.
#
#   fsm.transitions_for[:confirm] = { :new => :confirmed }
#   fsm.transitions_for[:ignore] = { :new => :ignored }
#   fsm.transitions_for[:reset] = { :confirmed => :new, :ignored => :new }
#
#   fsm.trigger(:confirm)  #=> true
#   fsm.trigger(:ignore)   #=> false
#   fsm.trigger(:reset)    #=> true
#   fsm.trigger(:ignore)   #=> true
#
class MicroMachine
  attr :transitions_for
  attr :state

  def initialize initial_state
    @state = initial_state
    @transitions_for = Hash.new
  end

  def trigger event
    if transitions_for[event][@state]
      @state = transitions_for[event][@state]
    end
  end
end
