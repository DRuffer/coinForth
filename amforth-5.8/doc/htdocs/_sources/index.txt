
AmForth
=======

AmForth is an easily extendible command interpreter for the Atmel
AVR8 Atmega micro controller family and some variants of the
TI MSP430. It has a turnkey feature for embedded use too.

AmForth is published under the GNU Public License v3 (GPL).
A commercial use is possible but for traditional commercial 
uses there are commercial Forths --- amForth just is not one 
of them.

AmForth runs completely on the controller. It does not need additional
hardware. It makes no restrictions for hardware extensions that can be
connected to the controller. The default command prompt is in a serial 
terminal.

The command language is `Forth <http://www.forth.org/tutorials.html>`_.
AmForth implements an almost compatible `Forth 2012 
<http://http://www.forth200x.org/documents/html3/>`_ indirect 
threading 16bit Forth. 

AmForth needs 8 to 12 KB Flash memory, 80 bytes EEPROM, and 200 bytes
RAM for the core system. The MSP430 fits into 8KB flash.

Work In Progress
................

Here you'll find things that are not yet
released but will be part of the next release.
See the code section at Sourceforge to get the
`most recent sources <http://sourceforge.net/p/amforth/code/HEAD/tree/trunk/>`__

* core(MSP430): new :command:`:noname` and the :command:`defer` group of
  commands.
* core(All): words with the same name do the same (mostly).
* core(AVR8): introduce :command:`<builds`. Together with :command:`does>` saves 
  one flash erase cycle and makes the source work on the MSP430 as well.

1.2.2015: release 5.7
.......................

* core(ALL): :command:`name>interpret` and :command:`name>compile` added.
  New Recognizer :command:`rec:name` able to replace :command:`rec:word`. 
  Uses name tokens (Forth 2012) instead of execution tokens.
* core(ALL): Lots of bugfixes and regressions. The AVR port should be 
  fully usable again.
* core(MSP430): restructure of the init process: :command:`cold` 
  now transfers the data from INFO flash back to RAM if BASE is set and 
  :command:`SAVE` was executed. That way the user code now correctly 
  survives a restart. :command:`SAVE` is much like marker that 
  overwrites the previous state and gets no name.

22.12.2014: release 5.6
.......................

* core(AVR): :command:`icompare` got the same return flag semantics as 
  :command:`compare`. The :command:`leave` and :command:`?do` forward branches
  are now resolved at compile time, saves one cell per loop on the return 
  stack at runtime.
* core(AVR): interrupt vectors are moved from RAM to EEPROM. Saves RAM space
  and simplifies turnkey actions (remove any ``int!`` from your turnkey!)
* core: re-arranged source files: controller specific and common code.
* New architecture: MSP430 (G2553) as used in the :ref:`TI_LaunchPad_430` 
  with code from `Camelforth <http://www.camelforth.com>`__ and 
  `4€4th <http://www.somersetweb.com/4E4th/EN.html>`__.
* core: generalized existing :ref:`Stacks` in EEPROM into :command:`map-stack`, 
  :command:`get-stack` and :command:`set-stack`. Used for the search order
  and recognizer stacks.
* all: changed license to GPLv3.

More To Read
............

.. toctree::
   :maxdepth: 1

   UG/amforth_user
   faq
   TG/TG
   TG/Cookbook
   Recognizers
   TG/refcard
   history
