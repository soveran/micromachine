require_relative 'helper'

setup do
  machine = MicroMachine.new(:pending)
  machine.when(:confirm, pending: :confirmed)
  machine
end

test "pass the event name to the callbacks" do |machine|
  machine.on(:confirmed) do |event|
    assert_equal(:confirm, event)
  end

  machine.trigger(:confirm)
end

test "pass the event name and old state to the callbacks" do |machine|
  machine.on(:confirmed) do |event, old_state|
    assert_equal(:confirm, event)
    assert_equal(:pending, old_state)
  end

  machine.trigger(:confirm)
end

test "pass the event name and both states to the callbacks" do |machine|
  machine.on(:confirmed) do |event, old_state, new_state|
    assert_equal(:confirm, event)
    assert_equal(:pending, old_state)
    assert_equal(:confirmed, new_state)
  end

  machine.trigger(:confirm)
end
