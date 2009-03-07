require 'rubygems'
require 'micromachine'

fsm = MicroMachine.new(:pending)
fsm.events[:confirm]  = { :pending => :confirmed }
fsm.events[:ignore]   = { :pending => :ignored }
fsm.events[:reset]    = { :confirmed => :pending, :ignored => :pending }

puts "Should print Confirmed, Reset and Ignored."

if fsm.fire(:confirm)
  puts "Confirmed"
end

if fsm.fire(:ignore)
  puts "Ignored"
end

if fsm.fire(:reset)
  puts "Reset"
end

if fsm.fire(:ignore)
  puts "Ignored"
end
