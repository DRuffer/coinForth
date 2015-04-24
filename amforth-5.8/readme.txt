Date: 17.1.2015

Author:
    Matthias Trute <mtrute@users.sourceforge.net>

Major Contributors:
    Erich Waelde
    Michael Kalus
    Leon Maurer
    Ullrich Hoffmann
    Karl Lund
    Enoch
    Bradford Rodriguez (MSP430 code)

License: General Public License (GPL) Version 3 from 2007. See the
file LICENSE.txt or http://www.gnu.org/licenses/gpl.html

AmForth is an interactive 16-bit Forth for Atmel ATmega and
Texas Instruments MSP430 microcontrollers. It does not need
additional hard or software. It works completely on the 
controller (no cross-compiler). AmForth uses the indirect
threading forth implementation technique.

ATmega:

  The forth dictionary is in the flash memory, new words are compiled
  directly into flash. Since no (widely available) bootloader supports
  an API to write to flash, AmForth needs to replace it.

MSP430
  
  The Forth dictionary is in the flash memory, new words are
  compiled to flash. Use SAVE to keep the code accessible across
  reboots. 

AmForth is implemented in assembly and forth. The code is stable
and well tested. The MSP430 variant is less tested however. It
has less features as well.

All words have ans94-draft6 (CORE and various extension word sets)
and forth 2012 stack diagrams, but not necessarily the complete
semantics. Some words from the standards are left out, ask for them
if you need them.

Development hardware are evaluation boards running various Amega's
between 2 and 20 MHz with various external hardware: none,
led, push-buttons, SD-card, ethernet controller, RF module etc.
The MSP430 is tested with the Stellaris Launchpad MSP430G2553.

Documentation can be found in the doc/ subdirectory and
on the homepage http://amforth.sourceforge.net/.

Contact, bug reports, questions, wishes etc:
    mailto:amforth-devel@lists.sourceforge.net
