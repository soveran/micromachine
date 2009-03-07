# Finite State Machine
#
# Usage:
#
#   fsm = MicroMachine.new(:new) # Initial state.
#
#   fsm.events[:confirm] = { :new => :confirmed }
#   fsm.events[:ignore] = { :new => :ignored }
#   fsm.events[:reset] = { :confirmed => :new, :ignored => :new }
#
#   fsm.fire(:confirm)  #=> true
#   fsm.fire(:ignore)   #=> false
#   fsm.fire(:reset)    #=> true
#   fsm.fire(:ignore)   #=> true
#
class MicroMachine
  attr :events
  attr :state

  def initialize initial_state
    @state = initial_state
    @events = Hash.new
  end

  def fire event
    if events[event][@state]
      yield if block_given?
      @state = events[event][@state]
    end
  end
end
