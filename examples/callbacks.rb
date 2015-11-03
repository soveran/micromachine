require 'micromachine'

# This example can be run with ruby -I lib/ ./examples/callbacks.rb

fsm = MicroMachine.new(:pending)

fsm.when(:confirm,  :pending => :confirmed)
fsm.when(:ignore,   :pending => :ignored)
fsm.when(:reset,    :confirmed => :pending, :ignored => :pending)

puts "Should print Confirmed, Reset and Ignored:"

fsm.on(:confirmed) do
  puts "Confirmed"
end

fsm.on(:ignored) do
  puts "Ignored"
end

fsm.on(:pending) do
  puts "Reset"
end

fsm.trigger(:confirm)

fsm.trigger(:ignore)

fsm.trigger(:reset)

fsm.trigger(:ignore)
