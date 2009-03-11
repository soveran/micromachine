MicroMachine
============

Minimal Finite State Machine.

Description
-----------

There are many finite state machine implementations for Ruby, and they
all provide a nice DSL for declaring events, exceptions, callbacks,
and all kinds of niceties in general.

But if all you want is a finite state machine, look no further: this is only
15 lines of code and provides everything a finite state machine must have, and
nothing more.

Usage
-----

    require 'micromachine'

    fsm = MicroMachine.new(:new) # Initial state.

    fsm.transitions_for[:confirm] = { :new => :confirmed }
    fsm.transitions_for[:ignore]  = { :new => :ignored }
    fsm.transitions_for[:reset]   = { :confirmed => :new, :ignored => :new }

    fsm.fire(:confirm)  #=> true
    fsm.fire(:ignore)   #=> false
    fsm.fire(:reset)    #=> true
    fsm.fire(:ignore)   #=> true

Installation
------------

    $ gem sources -a http://gems.github.com (you only have to do this once)
    $ sudo gem install soveran-micromachine

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
