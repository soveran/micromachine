require 'test/unit'

require File.dirname(__FILE__) + "/../lib/micromachine"

class MicroMachineTest < Test::Unit::TestCase

  def setup
    @machine = MicroMachine.new(:pending)
    @machine.transitions_for[:confirm]  = { :pending => :confirmed }
    @machine.transitions_for[:ignore]   = { :pending => :ignored }
    @machine.transitions_for[:reset]    = { :confirmed => :pending, :ignored => :pending }
  end

  def test_initial_state
    assert_equal :pending, @machine.state
  end

  def test_transitions
    assert @machine.trigger(:confirm)
    assert_equal :confirmed, @machine.state

    assert !@machine.trigger(:ignore)
    assert_equal :confirmed, @machine.state

    assert @machine.trigger(:reset)
    assert_equal :pending, @machine.state

    assert @machine.trigger(:ignore)
    assert_equal :ignored, @machine.state
  end
end
