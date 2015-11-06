require_relative "helper"

setup do
  machine = MicroMachine.new(:pending)
  machine.when(:confirm, pending: :confirmed)
  machine.when(:reset, confirmed: :pending)

  machine.on(:pending)   { @state = "Pending" }
  machine.on(:confirmed) { @state = "Confirmed" }
  machine.on(:any)       { @current = @state }

  machine
end

test "executes callbacks when entering a state" do |machine|
  machine.trigger(:confirm)
  assert_equal "Confirmed", @state

  machine.trigger(:reset)
  assert_equal "Pending", @state
end

test "executes the callback on any transition" do |machine|
  machine.trigger(:confirm)
  assert_equal "Confirmed", @current

  machine.trigger(:reset)
  assert_equal "Pending", @current
end

test "raises error on wrong number of arguments on callback" do
  machine = MicroMachine.new(:pending)
  machine.when(:confirm, pending: :confirmed)

  assert_raise ArgumentError do
    machine.on(:confirmed) do |a, b, c, d|
    end
  end
end

test 'passing nothing to the callbacks' do
  callback_called = nil

  machine = MicroMachine.new(:pending)
  machine.when(:confirm, pending: :confirmed)

  machine.on(:confirmed) do
    callback_called = true
  end

  machine.trigger(:confirm)

  assert callback_called
end

test "passing the event name to the callbacks" do
  event_name = nil

  machine = MicroMachine.new(:pending)
  machine.when(:confirm, pending: :confirmed)

  machine.on(:confirmed) do |event|
    event_name = event
  end

  machine.trigger(:confirm)

  assert_equal(:confirm, event_name)
end

test "passing the event name and previous state to the callbacks" do
  event_name, previous_state_name = nil

  machine = MicroMachine.new(:pending)
  machine.when(:confirm, pending: :confirmed)

  machine.on(:confirmed) do |event, previous_state|
    event_name = event
    previous_state_name = previous_state
  end

  machine.trigger(:confirm)

  assert_equal(:confirm, event_name)
  assert_equal(:pending, previous_state_name)
end

test "passing the event name, previous and current state to the callbacks" do
  event_name, previous_state_name, current_state_name = nil

  machine = MicroMachine.new(:pending)
  machine.when(:confirm, pending: :confirmed)

  machine.on(:confirmed) do |event, previous_state, current_state|
    event_name = event
    previous_state_name = previous_state
    current_state_name = current_state
  end

  machine.trigger(:confirm)

  assert_equal(:confirm, event_name)
  assert_equal(:pending, previous_state_name)
  assert_equal(:confirmed, current_state_name)
end

test "passing the everything to the callbacks" do
  event_name, previous_state_name, current_state_name = nil

  machine = MicroMachine.new(:pending)
  machine.when(:confirm, pending: :confirmed)

  machine.on(:confirmed) do |*args|
    event_name, previous_state_name, current_state_name = args
  end

  machine.trigger(:confirm)

  assert_equal(:confirm, event_name)
  assert_equal(:pending, previous_state_name)
  assert_equal(:confirmed, current_state_name)
end
