require_relative 'helper'

setup do
  klass = Class.new do
    attr_reader :event, :old_state, :new_state, :called

    def initialize
      @event = @old_state = @new_state = nil
      @called = false
    end

    def no_args
      @called = true
    end

    def one_arg(event)
      @event = event
      @called = true
    end

    def two_args(event, old_state)
      @event, @old_state = event, old_state
      @called = true
    end

    def three_args(event, old_state, new_state)
      @event, @old_state, @new_state = event, old_state, new_state
      @called = true
    end
  end

  machine = MicroMachine.new(:pending)
  machine.when(:confirm, pending: :confirmed)

  [ klass.new, machine ]
end

test "does not raise an exception when arity is 0" do |object, machine|
  machine.on(:confirmed, &object.method(:no_args))

  assert !object.called

  assert_nothing_raised { machine.trigger(:confirm) }
  assert object.called
  assert object.event.nil?
  assert object.old_state.nil?
  assert object.new_state.nil?
end

test "gets the event only when arity is 1" do |object, machine|
  machine.on(:confirmed, &object.method(:one_arg))

  assert !object.called

  assert_nothing_raised { machine.trigger(:confirm) }
  assert object.called
  assert_equal(:confirm, object.event)
  assert object.old_state.nil?
  assert object.new_state.nil?
end

test "gets the event and old state when arity is 2" do |object, machine|
  machine.on(:confirmed, &object.method(:two_args))

  assert !object.called

  assert_nothing_raised { machine.trigger(:confirm) }
  assert object.called
  assert_equal(:confirm, object.event)
  assert_equal(:pending, object.old_state)
  assert object.new_state.nil?
end

test "gets the event and both states when arity is 3" do |object, machine|
  machine.on(:confirmed, &object.method(:three_args))

  assert !object.called

  assert_nothing_raised { machine.trigger(:confirm) }
  assert object.called
  assert_equal(:confirm, object.event)
  assert_equal(:pending, object.old_state)
  assert_equal(:confirmed, object.new_state)
end
