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
      @machine.transitions_for[:nullify]  = { :any => :nulled }
    end

    should "have an initial state" do
      assert_equal :pending, @machine.state
    end

    should "discern transitions" do
      assert_equal true, @machine.trigger?(:confirm)
      assert_equal true, @machine.trigger(:confirm)
      assert_equal :confirmed, @machine.state

      assert_equal false, @machine.trigger?(:ignore)
      assert_equal false, @machine.trigger(:ignore)
      assert_equal :confirmed, @machine.state

      assert_equal true, @machine.trigger?(:reset)
      assert_equal true, @machine.trigger(:reset)
      assert_equal :pending, @machine.state

      assert_equal true, @machine.trigger?(:ignore)
      assert_equal true, @machine.trigger(:ignore)
      assert_equal :ignored, @machine.state

      assert_equal true, @machine.trigger?(:nullify)
      assert_equal true, @machine.trigger(:nullify)
      assert_equal :nulled, @machine.state
    end

    should "raise an error if an invalid event is triggered" do
      assert_raise MicroMachine::InvalidEvent do
        @machine.trigger(:random_event)
      end
    end

    should "raise an error if event is triggered from/to a non complatible state with trigger!" do
      assert_raise MicroMachine::InvalidState do
        @machine.trigger!(:reset)
      end
    end

    should "not raise an error if event is triggered from/to a non complatible state and exception flag not activated" do
      assert_nothing_raised do
        @machine.trigger(:reset)
      end
    end
  end

  context "using when for defining transitions" do
    setup do
      @machine = MicroMachine.new(:pending)
      @machine.when(:confirm, :pending => :confirmed)
      @machine.when(:ignore, :pending => :ignored)
      @machine.when(:reset, :confirmed => :pending, :ignored => :pending)
      @machine.when(:nullify, :any => :nulled)
    end

    should "discern transitions" do
      assert_equal true, @machine.trigger?(:confirm)
      assert_equal true, @machine.trigger(:confirm)
      assert_equal :confirmed, @machine.state

      assert_equal false, @machine.trigger?(:ignore)
      assert_equal false, @machine.trigger(:ignore)
      assert_equal :confirmed, @machine.state

      assert_equal true, @machine.trigger?(:reset)
      assert_equal true, @machine.trigger(:reset)
      assert_equal :pending, @machine.state

      assert_equal true, @machine.trigger?(:ignore)
      assert_equal true, @machine.trigger(:ignore)
      assert_equal :ignored, @machine.state

      assert_equal true, @machine.trigger?(:nullify)
      assert_equal true, @machine.trigger(:nullify)
      assert_equal :nulled, @machine.state
    end
  end

  context "dealing with callbacks" do
    setup do
      @machine = MicroMachine.new(:pending)
      @machine.when(:confirm, :pending => :confirmed)
      @machine.when(:ignore, :pending => :ignored)
      @machine.when(:reset, :confirmed => :pending, :ignored => :pending)
      @machine.when(:nullify, :any => :nulled)

      @machine.on(:pending)   { @state = "Pending" }
      @machine.on(:confirmed) { @state = "Confirmed" }
      @machine.on(:ignored)   { @state = "Ignored" }
      @machine.on(:nulled)   { @state = "Nulled" }
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

      @machine.trigger(:nullify)
      assert_equal "Nulled", @state
      assert_equal "Nulled", @current
    end
  end

  context "dealing with from a model callbacks" do
    class Model
      attr_accessor :state

      def machine
        @machine ||= begin
          machine = MicroMachine.new(:pending)
          machine.when(:confirm, :pending => :confirmed)
          machine.when(:ignore, :pending => :ignored)
          machine.when(:reset, :confirmed => :pending, :ignored => :pending)
	  machine.when(:nullify, :any => :nulled)
          machine.on(:any) { self.state = machine.state }
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

      @model.machine.trigger(:nullify)
      assert_equal :nulled, @model.machine.state
      assert_equal :nulled, @model.state
    end
  end

  context 'introspection' do
    setup do
      @machine = MicroMachine.new(:pending)
      @machine.transitions_for[:confirm]  = { :pending => :confirmed }
      @machine.transitions_for[:ignore]   = { :pending => :ignored }
      @machine.transitions_for[:reset]    = { :confirmed => :pending, :ignored => :pending }
      @machine.transitions_for[:nullify]  = { :any => :nulled }
    end

    should 'return a list of defined events' do
      assert_equal [:confirm, :ignore, :reset, :nullify], @machine.events
    end

    should 'return a list of defined states' do
      assert_equal [:pending, :confirmed, :ignored, :nulled], @machine.states
    end
  end
end
