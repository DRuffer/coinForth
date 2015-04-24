.. _TI-Raspberry:

Amforth with Raspberry PI
=========================

No, this recipe is not abot using amforth *on* the Raspberry 
PI, but use the RPi as the development platform *for* the
microcontrollers it supports.

Compiling amforth for the Atmegas requires the Atmel
Assembler which runs only on some, widespread however,
platforms like Windows and x86 Linux with wine.
It is however possible to use the `avrdude` program
to flash the controller.

The MSP430 variant got the full toolchain working.
The necessary tools `naken_asm` and `mspdebug` work
fine.

Installation
-------------

The setup has been tested with pidora, other linux's should
work the same way.

The `mspdebug` utility requires direct access to the USB
port. This can be either achieved by running it as root
or (better) by adding a file `/etc/udev/rules.d/46-TI-Launchpad.rules`
with the content (a single line)

.. code-block:: none

   ATTRS{idVendor}=="0451", ATTRS{idProduct}=="f432", MODE="0660", GROUP="plugdev"

Restart udev afterwards and re-plug the launchpad. The user account you're 
using has to become a member of the plugdev group. Check with `id`, re-login
if necessary.

The `naken_asm` is installed from the sources. Just follow the instructions.

Other tools are the `make` utility (or ant), the editor and the terminal program.
