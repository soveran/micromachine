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
    @events = Hash.new { |hash, key| hash[:key] = [] }
  end

  def fire event
    if new_state = events[event][@state]
      yield if block_given?
      @state = new_state
    end
  end
end
