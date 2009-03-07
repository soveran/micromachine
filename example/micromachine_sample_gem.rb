require 'rubygems'
require 'micromachine'

fsm = MicroMachine.new(:pending)
fsm.events[:confirm]  = { :pending => :confirmed }
fsm.events[:ignore]   = { :pending => :ignored }
fsm.events[:reset]    = { :confirmed => :pending, :ignored => :pending }

puts "Should print Confirmed, Reset and Ignored."

fsm.fire(:confirm) do
  puts "Confirmed"
end

fsm.fire(:ignore) do
  puts "Ignored"
end

fsm.fire(:reset) do
  puts "Reset"
end

fsm.fire(:ignore) do
  puts "Ignored"
end
