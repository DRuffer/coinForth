.. _Defer:

==============
Deferred Words
==============

Deferred words a technique that allows to change the behaviour of
a word at runtime. This is done by storing an execution token under
a certain name that is executed whenever that name is called. The stack
effect is entirely that of the stored execution token code. The basic
specification is at `www.forth200x.org/deferred.html 
<http://www.forth200x.org/deferred.html>`_ which is a must-read now.

Amforth supports different locations to store the execution
token. The AVR8 provides  3 different variants: :command:`Edefer` stores 
in EEPROM, :command:`Rdefer` stores in RAM and :command:`Udefer` stores 
in the USER area. The MSP430 has only RAM (Rdefer) since flash is
not changeable, except the info flash area.

Depending on the storage location, different initalization actions 
may be required at startup. Only the AVR8 EEPROM based defers work
without further actions and every changes are kept likewise.

Assigning a new execution token uses the command :command:`IS`
for all defers, regardless of the actual location used.

AmForth uses the deferred words technique internally:

* :command:`turnkey` is an EEPROM (AVR8) or info flash (MSP430) 
  based deferred word that is executed from :command:`QUIT` 
  during startup and reset.
* the words :command:`key`, :command:`key?`,
  :command:`emit`, and :command:`emit?` are USER
  deferred words for low level terminal IO. (AVR8)
* :command:`refill` and :command:`source` are
  USER deferred words used by the forth interpreter
  to get the next command line.
* :command:`pause` is a RAM based deferred word
  that is called whenever a task switch can be done.
  It is set to :command:`noop` per default.
* :command:`!i` does the actual flash write of a single
  cell. It is intended for :ref:`Unbreakable` (AVR8)

Since there is no standard :command:`defer` word, the developer
has to choose where to store the execution tokens. An EEPROM 
location is keept over resets/restarts and is valid 
without further initialization. A USER based deferred word 
can be targeted to different words in a multitasking environment 
and finally a RAM based deferred word can be changed frequently. 

How Defers work
===============

Defers store an execution token. When the name of the defered
word is called, they fetch this token and execute it. When the
name is  compiled into another definition, this fetch-execute
happens when calling this other word. That way even a compiled
deferred word can be changed later on since it's only the defer
definition that got compiled, not its content.

.. code-block:: forth

   > Xdefer foo
   > : bar foo ;
   > ' words is foo 
   > bar
    <long list of words>
   > ' noop is foo
   > bar
    <nothing>
   >

:command:`Xdefer` is one of the various defer defining word.
Regardless of the actual type, all defers behave the same way.

The defer defining words are created with the same design:

.. code-block:: forth

   : Rdefer ( "name" -- )
       (defer)
       here , 2 allot
       [: @i @ ;] , \ used to read
       [: @i ! ;] , \ used by IS
   ;

The first command :command:`(defer)` creates the dictionary entry "name"
and sets up the runtime behaviour (execution token). The next line allocates
a memory region (RAM in the example) and compiles its address. The two
quotations are called to access the data item. They are called with the
address of the compiled address (thus the :command:`@i`). That way two
memory accesses are performed: first is to get the address from the
dictionary entry the second to fetch/store from/to the address in 
the right memory pool.


Sealing Defers
==============

It is sometimes necessairy to prevent a deferred word from
changing. This can be achieved with the following word

.. code-block:: forth

   : defer:seal ( XT -- )
    dup defer@ ( -- XT' XT )
    swap ( -- XT XT')
    dup ['] quit @i ( get DO_COLON) swap !i
    1+   dup rot swap !i
    1+ ['] exit swap !i
   ;


With it, the dictionary entry is patched directly to
change it from beeing a defer to a colon word named as
the deferred word calling only the current XT stored in
it

.. code-block:: forth

   (ATmega32)> Edefer mytest
    ok
   (ATmega32)> ' ver is mytest
    ok
   (ATmega32)> mytest
    amforth 5.3 ATmega32 ok
   (ATmega32)> ' mytest 5 - 10 idump
    10E0 - FF06 796D 6574 7473 10CB 0836 005C 07D6   ..mytest..6.\...
    10E8 - 07E0 FFFF ...
    ok
   (ATmega32)> ' mytest defer:seal 
    ok
   (ATmega32)> ' mytest 5 - 10 idump
    10E0 - FF06 796D 6574 7473 10CB 3800 078C 381A   ..mytest...8...8
    10E8 - 07E0 FFFF ...
    ok
   (ATmega32)> mytest
    amforth 5.3 ATmega32 ok
   (ATmega32)> 

Technically the word ``mytest`` is changed to the same dictionary
content as if it was defined as

.. code-block:: forth

   : mytest ver ;

This is possible since a deferred word occupies 3 flash cells in the body
and the faked colon definition needs only 2: the XT of the deferred word
and the exit call.
