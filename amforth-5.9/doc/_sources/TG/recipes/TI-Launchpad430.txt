.. _TI_Launchpad_430:

Texas Instruments LaunchPad 430
===============================

Texas Instruments has the MSP430 microcontroller
familiy. It is completely different to the AVR
Atmegas. Amforth recently started to support it
as well. The Forth kernel is (almost) the same,
many tools like the amforth-shell work for both
too. Since the MSP430 is new, bugs and other oddities
are more likely than for the Atmegas.

Getting started on linux with mspdebug
--------------------------------------

The sources are made for the 
`naken_asm <http://www.mikekohn.net/micro/naken_asm.php>`__
assembler. 

Connect your Launchpad to the USB port of your PC.
It may take a while until the modem manager detects
that it is not a device it can handle. Now open a 
terminal (I use minicom) and set the serial port 
settings: `/dev/acm0`, 9600 and 8N1 without flow 
control. Nothing's happening so far.

Open another shell command window and navigate to
the launchpad430 directory. There is a hex file with
the compiled amforth. Try `ant compile` to get it.

Now run mspdebug to actually program the controller

.. code-block:: bash

   > mspdebug rf2500 "prog launchpad430.hex "
    MSPDebug version 0.22 - debugging tool for MSP430 MCUs
    Copyright (C) 2009-2013 Daniel Beer <dlbeer@gmail.com>
    This is free software; see the source for copying conditions.  There is NO
    warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    Trying to open interface 1 on 007
    rf2500: warning: can't detach kernel driver: No data available
    Initializing FET...
    FET protocol version is 30394216
    Set Vcc: 3000 mV
    Configured for Spy-Bi-Wire
    fet: FET returned error code 4 (Could not find device or device not supported)
    fet: command C_IDENT1 failed
    Using Olimex identification procedure
    Device ID: 0x2553
      Code start address: 0xc000
      Code size         : 16384 byte = 16 kb
      RAM  start address: 0x200
      RAM  end   address: 0x3ff
      RAM  size         : 512 byte = 0 kb
    Device: MSP430G2xx3
    Number of breakpoints: 2
    fet: FET returned NAK
    warning: device does not support power profiling
    Chip ID data: 25 53
    Erasing...
    Programming...
    Writing  424 bytes at 0200...
    Writing  188 bytes at 1000...
    Writing 4096 bytes at e000...
    Writing 4008 bytes at f000...
    Writing   32 bytes at ffe0...
    Done, 8748 bytes total

Your Amforth terminal session (minicom) should now print some readable
characters like

.. code-block:: none

   +-------------------------------------
   | amforth 5.6 MSP430G2553 8000 kHz 
   | >
   |

Thats all. If nothing has happened look for error messages
in the mspdebug window. Try replugging the launchpad. Some
more information are in the :ref:`TI-Raspberry` recipe.

You can reprogram the controller via USB whilst the terminal
session is still active. In this case you'll see repeated 
welcome strings from amforth due to some resets.

.. code-block:: none

   +-------------------------------------
   | amforth 5.6 MSP430G2553 8000 kHz 
   | > amforth 5.6 MSP430G2553 8000 kHz 
   | > amforth 5.6 MSP430G2553 8000 kHz 
   | > amforth 5.6 MSP430G2553 8000 kHz 
   | > amforth 5.6 MSP430G2553 8000 kHz 
   | >
   |


Playing with the Launchpad
--------------------------

The LEDs can be used as follows

.. code-block:: forth

   : red:init   1 34 bm-set ;
   : red:on     1 33 bm-set ;
   : red:off    1 33 bm-clear ;
   : green:init 64 34 bm-set ;
   : green:on   64 33 bm-set ;
   : green:off  64 33 bm-clear ;


Example for (machine) code (instead of 
the forth code above)

.. code-blocK:: forth

   code red:on  $D3D2 , $0021 , end-code
   code red:off $C3D2 , $0021 , end-code

There are many ways to wait, e.g. do other
things while waiting (`PAUSE`). A simple 
approach is do nothing:

.. code-blocK:: forth
 
   : ms 0 ?do 1ms loop ;                                                         

Now let the red LED blink ONCE

.. code-blocK:: forth

   : blink red:on 100 ms red:off 100 ms ;                                          

Test it! Now! The compiled version is *much* 
faster than the sequence "1 33 bm-set 1 33 bm-clear"
(watch the red flashes). Next is to let it blink until 
a key is pressed

.. code-blocK:: forth

   : blink-forever begin blink key? until key drop ;                                        

