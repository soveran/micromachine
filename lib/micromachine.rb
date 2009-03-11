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
