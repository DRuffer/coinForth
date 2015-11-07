.. _Stacks:

====================
Configuration Stacks
====================

In Forth stacks are ubiquitous. Not only the data stack and
the returnstack are used but many more can be found. Some of
them hold configuration data like the search order stack which 
contains the wordlist-id's for the interpreter. Amforth got 
the recognizers as an additional core level stack. All these 
stacks are placed in the EEPROM storage and they have a few 
things in common:

* they are used at system level.
* they are seldom changed.
* they are used with an iterator.

EEPROM Layout
-------------

A stack is a contiguus eeprom space. The first cell
has the actual stack depth, followed by the stack
elements.

.. code-block:: forth
 
   \ create a 11 elements stack
   > edp constant a-stack 12 cells eallot

The constant ``a-stack`` is used to further work with the
stack.

Commands
--------

There are three basic stack commands: 

* :command:`get-stack` and :command:`set-stack`
  transfer the whole stack content to/from the data stack.
  That makes it possible to change the stack with the standard
  stack commands. Note, that the top-of-stack contains the actual
  stack depth.

* :command:`map-stack`
  The iterator calls a predefined word for every stack
  element and leaves the iteration if the action word
  tells to do so

get/set-stack
.............

These commands transfer the data to/from the eeprom storage from/to
the data stack. Only the actual stack depth is transferred.

map-stack
.........

The :command:`map-stack` command is the stack iterator. It calls
an execution token for every stack element. The execution token
is expeced to return a flag to decide whether the iteration continues
or shall be ended prematurly. The command ``map-stack`` itself leaves
a flag that informs about this termination cause. True means that
a premature exit has been done, false means that the iteration
was made for all elements.

The execution token is a nice example for :ref:`Quotations`.
What it does is to use the stack element and generate a 
flag. If the flag is false (0), the data stack should be
unchanged to make another iteration possible. If the flag
is true (-1), the data stack can be changed to the final result.

The word called gets the actual stack element as the parameter.
A flag is the return value. A true means, that this call was the
last one, a false means, that the stack iteration continues with
the next element.

A simple example is printing the word names of the recognizer
stack. The EE_RECOGNIZERLISTLEN is a constant with the EEPROM
address of the recognizer stack. The quotation extracts the
name and prints it. The false flag makes sure, that every
stack member is called. Since the final result of the iteration
is not relevant, it gets simply dropped.

.. code-block:: forth

   : .recs 
     [: ( XT -- false )
        >name icount $ff and itype space 0
     ;]
     EE_RECOGNIZERLISTLEN map-stack drop
   ;

A slightly more complex iterator is the dictionary lookup
word. It has to use the addr/len information for each
wordlist from the ORDER stack. That makes it necessary to
keep this information inside the quotation.

.. code-block:: forth

   : find-name ( addr len -- xt +/-1 | 0)
      [: ( addr len wid -- xt +/-1 -1 | addr len 0 ) 
         >r 2dup r>
         search-wordlist
         dup 0<> if >r nip nip r> -1 then
      ;] 
      EE_ORDERLISTLEN  map-stack 
      0= if 2drop 0 then
   ;

Since the quotation already deletes the addr/len from the
data stack if the word is found, this cleanup is only
necessary if no word could be found at all.

A similiar example is used for the recognizer stack. The main
difference is the other meaning of the stack element and
another iteration abort condition.

.. code-block:: forth

   : do-recognizer ( addr len -- i*x r:table|r:fail )
     [: ( addr len rec:XT -- i*x r:table -1 | addr len 0 )
        rot rot 2dup 2>r rot 
        execute 
        2r> rot dup r:fail =
        if drop 0 else nip nip -1 then
     ;] 
     EE_RECOGNIZERLISTLEN map-stack ( -- i*x addr len r:table f )
     0= if \ no recognizer did the job, cleanup and add r:fail as default result
      2drop r:fail 
     then ;
