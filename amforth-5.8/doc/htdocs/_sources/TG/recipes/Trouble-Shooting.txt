
Trouble Shooting
================

There are several pit falls, one may fall into. There are
two milestones for a working amforth: A working 
command prompt and a successful compilation.

No prompt
---------

By experience: check your hardware. Check whether you use the
serial port that you configured in amforth. Many atmegas have
more than one serial port and usually the wrong one is configured.

Next check the baud rate *and* the cpu frequency. They must match 
the configured numbers. There are some fuses as well that affect 
the cpu frequency. Check them too!

Failed to compile
-----------------

If your prompt works, the compile step may fail as well. A definition
may not return to the command prompt or any further command fails 
without any message. There are usually two reasons: The fuses and 
the fuses.

Amforth requires that the whole NRWW section is used for the
bootloader. If the bootloader section is smaller than the
maximum (largest) NRWW size, compilation fails.

Another sensitive fuse is the boot reset vector (bootrst). It 
*has to* point to address 0, *not* to the NRWW section. Usually
it means to set it to off value.

