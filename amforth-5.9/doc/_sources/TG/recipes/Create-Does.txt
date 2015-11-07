==================
Using create/does>
==================

The command combination :command:`create` .. :command:`does>`
creates a challange on a microcontroller forth which dictionary 
resides in flash memory since :command:`create` writes the
execution token. A subsequent :command:`does>` *replaces* this
execution token with some other value. The AVR can reprogram
it on the fly, the MSP430 places a much higher burden to achieve
it. Due to the size of a single flash page the the sequence 
``create/does>`` works on the AVR8 only. 

The combination ``<builds/does>`` works on all platforms
without restrictions as a plug-in replacement.

A subtle error will be made with the following code

.. code-block:: forth

   : const create , does> @ ;

This code does *not* work as expected. The value compiled with ``,``
is compiled into the dictionary, which is read using the ``@i`` word. The
correct code is

.. code-block:: forth

   : const create , does> @i ;

Similarly the sequence

.. code-block:: forth

   : world create ( sizeinformation )  allot
     does> ( size is on stack) ... ;

does not work. It needs to be changed to

.. code-block:: forth

   : world variable ( sizeinformation) allot
    does> @i ( sizeinformation is now on stack) ... ;
   ;

.. seealso:: :ref:`Arrays` :ref:`Builds`
