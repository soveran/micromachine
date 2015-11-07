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