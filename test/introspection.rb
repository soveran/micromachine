require_relative "helper"

setup do
  machine = MicroMachine.new(:pending)

  machine.when(:confirm, pending: :confirmed)
  machine.when(:ignore, pending: :ignored)
  machine.when(:reset, confirmed: :pending, ignored: :pending)

  machine
end

test "returns an array with the defined events" do |machine|
  assert_equal [:confirm, :ignore, :reset], machine.events
end

test "returns an array with the defined states" do |machine|
  assert_equal [:pending, :confirmed, :ignored], machine.states
end

test "returns false if compared state is not equal to current" do |machine|
  assert !(machine == :confirmed)
end

test "returns true if compared state is equal to current" do |machine|
  assert machine == :pending
end
