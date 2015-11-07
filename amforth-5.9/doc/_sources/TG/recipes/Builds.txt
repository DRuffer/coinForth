.. _Builds:

================
<BUILDS / DOES> 
================

:command:`<builds` is the older sibling of :command:`create`.
It has been in use in pre-ANSI Forth's and is still around as
an supplemental tool. It is a parsing word that takes the next
word from the input source and creates a dictionary entry in
the current word list. Unlike :command:`create` it does not
add an execution token. Thus the word list entry created 
is unfinished and calling it *will* crash the system.

The definition of the word list entry is finished with the
:command:`does>` section, that makes the word list entry
a proper callable word.

The big advantage over :command:`create` is that :command:`create`
requires a rewrite of the contents of the execution token. That
is on microcontrollers with the flash based dictionary only possible
if a single cell can be re-programmed. The Atmegas can do that with
little efforts, the MSP430 lacks essential ressources to do so.

From the programming perspective there are no differences. :command:`<builds`
can safely replace :command:`create` in defining words that contain a
:command:`does>` section as well. All other occurances of :command:`create`
should remain unchanged.

.. code-block:: forth

   : constant create , does> @i ;
   \ or
   : constant <builds , does> @i ;
