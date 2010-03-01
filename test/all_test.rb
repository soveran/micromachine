require 'test/unit'
require 'rubygems'
require 'contest'

require File.dirname(__FILE__) + "/../lib/micromachine"

class MicroMachineTest < Test::Unit::TestCase
  context "basic interaction" do
    setup do
      @machine = MicroMachine.new(:pending)
      @machine.transitions_for[:confirm]  = { :pending => :confirmed }
      @machine.transitions_for[:ignore]   = { :pending => :ignored }
      @machine.transitions_for[:reset]    = { :confirmed => :pending, :ignored => :pending }
    end

    should "have an initial state" do
      assert_equal :pending, @machine.state
    end

    should "discern transitions" do
      assert @machine.trigger?(:confirm)
      assert @machine.trigger(:confirm)
      assert_equal :confirmed, @machine.state

      assert !@machine.trigger?(:ignore)
      assert !@machine.trigger(:ignore)
      assert_equal :confirmed, @machine.state

      assert @machine.trigger?(:reset)
      assert @machine.trigger(:reset)
      assert_equal :pending, @machine.state

      assert @machine.trigger?(:ignore)
      assert @machine.trigger(:ignore)
      assert_equal :ignored, @machine.state
    end

    should "raise an error if an invalid event is triggered" do
      assert_raise MicroMachine::InvalidEvent do
        @machine.trigger(:random_event)
      end
    end
  end

  context "dealing with callbacks" do
    setup do
      @machine = MicroMachine.new(:pending)
      @machine.transitions_for[:confirm]  = { :pending => :confirmed }
      @machine.transitions_for[:ignore]   = { :pending => :ignored }
      @machine.transitions_for[:reset]    = { :confirmed => :pending, :ignored => :pending }

      @machine.on(:pending)   { @state = "Pending" }
      @machine.on(:confirmed) { @state = "Confirmed" }
      @machine.on(:ignored)   { @state = "Ignored" }
      @machine.on(:any)       { @current = @state }
    end

    should "execute callbacks when entering a state" do
      @machine.trigger(:confirm)
      assert_equal "Confirmed", @state
      assert_equal "Confirmed", @current

      @machine.trigger(:ignore)
      assert_equal "Confirmed", @state
      assert_equal "Confirmed", @current

      @machine.trigger(:reset)
      assert_equal "Pending", @state
      assert_equal "Pending", @current

      @machine.trigger(:ignore)
      assert_equal "Ignored", @state
      assert_equal "Ignored", @current
    end
  end

  context "dealing with from a model callbacks" do
    class Model
      attr_accessor :state

      def machine
        @machine ||= begin
                       machine = MicroMachine.new(:pending)
                       machine.transitions_for[:confirm]  = { :pending => :confirmed }
                       machine.transitions_for[:ignore]   = { :pending => :ignored }
                       machine.transitions_for[:reset]    = { :confirmed => :pending, :ignored => :pending }
                       machine.on(:any)       { self.state = machine.state }
                       machine
                     end
      end
    end

    setup do
      @model = Model.new
    end

    should "execute the callback any when a state" do
      @model.machine.trigger(:confirm)
      assert_equal :confirmed, @model.machine.state
      assert_equal :confirmed, @model.state

      @model.machine.trigger(:ignore)
      assert_equal :confirmed, @model.machine.state
      assert_equal :confirmed, @model.state

      @model.machine.trigger(:reset)
      assert_equal :pending, @model.machine.state
      assert_equal :pending, @model.state

      @model.machine.trigger(:ignore)
      assert_equal :ignored, @model.machine.state
      assert_equal :ignored, @model.state
    end
  end
end
