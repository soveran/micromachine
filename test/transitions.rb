require_relative "helper"

setup do
  machine = MicroMachine.new(:pending)

  machine.when(:confirm, pending: :confirmed)
  machine.when(:ignore, pending: :ignored)
  machine.when(:reset, confirmed: :pending, ignored: :pending)

  machine
end

test "defines initial state" do |machine|
  assert_equal :pending, machine.state
  assert_equal nil, machine.previous_state
end

test "raises an error if an invalid event is triggered" do |machine|
  assert_raise(MicroMachine::InvalidEvent) do
    machine.trigger(:random_event)
  end
end

test "preserves the state if transition is not possible" do |machine|
  assert !machine.trigger?(:reset)
  assert !machine.trigger(:reset)
  assert_equal :pending, machine.state
  assert_equal nil, machine.previous_state
end

test "changes the state if transition is possible" do |machine|
  assert machine.trigger?(:confirm)
  assert machine.trigger(:confirm)
  assert_equal :confirmed, machine.state
  assert_equal :pending, machine.previous_state
end

test "discerns multiple transitions" do |machine|
  machine.trigger(:confirm)
  assert_equal :confirmed, machine.state
  assert_equal :pending, machine.previous_state

  machine.trigger(:reset)
  assert_equal :pending, machine.state
  assert_equal :confirmed, machine.previous_state

  machine.trigger(:ignore)
  assert_equal :ignored, machine.state
  assert_equal :pending, machine.previous_state

  machine.trigger(:reset)
  assert_equal :pending, machine.state
  assert_equal :ignored, machine.previous_state
end

test "raises an error if event is triggered from/to a non complatible state" do |machine|
  assert_raise(MicroMachine::InvalidState) do
    machine.trigger!(:reset)
  end
end
