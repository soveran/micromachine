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
