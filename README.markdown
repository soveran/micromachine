MicroMachine
============

Minimal Finite State Machine.

Description
-----------

There are many finite state machine implementations for Ruby, and they
all provide a nice DSL for declaring events, exceptions, callbacks,
and all kinds of niceties in general.

But if all you want is a finite state machine, look no further: this is only
22 lines of code and provides everything a finite state machine must have, and
nothing more.

Usage
-----

    require 'micromachine'

    machine = MicroMachine.new(:new) # Initial state.

    machine.transitions_for[:confirm] = { :new => :confirmed }
    machine.transitions_for[:ignore]  = { :new => :ignored }
    machine.transitions_for[:reset]   = { :confirmed => :new, :ignored => :new }

    machine.trigger(:confirm)  #=> true
    machine.trigger(:ignore)   #=> false
    machine.trigger(:reset)    #=> true
    machine.trigger(:ignore)   #=> true

It can also have callbacks when entering some state:

    machine.on(:confirmed) do
      puts "Confirmed"
    end

Or callbacks on any transition:

    machine.on(:any) do
      puts "Transitioned..."
    end

Adding MicroMachine to your models
----------------------------------

The most popular pattern among Ruby libraries that tackle this problem
is to extend the model and transform it into a finite state machine.
Instead of working as a mixin, MicroMachine's implementation is by
composition: you instantiate a finite state machine (or many!) inside
your model and you are in charge of querying and persisting the state.
Here's an example of how to use it with an ActiveRecord model:

    class Event < ActiveRecord::Base
      before_save :persist_confirmation

      def confirm!
        confirmation.trigger(:confirm)
      end

      def cancel!
        confirmation.trigger(:cancel)
      end

      def reset!
        confirmation.trigger(:reset)
      end

      def confirmation
        @confirmation ||= begin
          @confirmation = MicroMachine.new(confirmation_state || "pending")
          @confirmation.transitions_for[:confirm] = { "pending" => "confirmed" }
          @confirmation.transitions_for[:cancel] = { "confirmed" => "cancelled" }
          @confirmation.transitions_for[:reset] = { "confirmed" => "pending", "cancelled" => "pending" }
          @confirmation
        end
      end

    private

      def persist_confirmation
        self.confirmation_state = confirmation.state
      end
    end

This example asumes you have a :confirmation_state attribute in your
model. This may look like a very verbose implementation, but you gain a
lot in flexibility.

Installation
------------

    $ sudo gem install micromachine

License
-------

Copyright (c) 2009 Michel Martens for Citrusbyte

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
