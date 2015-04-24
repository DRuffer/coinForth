# coinForth
amforth 5.8 ATmega328P on the arduino-ble-dev-kit

amforth 5.8 ATmega328P Forthduino

I have a C:\amforth folder with versions 5.1, 5.3, 5.4, and now 5.8 in it, so I have been trying to do this for a while now. I finally noticed:

.equ F_CPU = 16000000 -> 8000000

and:

.set BAUD = 38400 

and thought I might try PuTTY at 19200 baud and pressed the reset button multiple times, until I got:

amforth 5.8 ATmega328P Forthduino

Not rocket science, and doesn't work or always take keyboard input, but encouraging. On the other hand:

Assembly failed, 39 errors, 44 warnings

And how to make:

Atmel Studio 6 (Version: 6.2.1563 - Service Pack 2) © 2014 Atmel Corp. All rights reserved.

Find the source files...

In the Project -> Properties -> Toolchain -> General, check Generate EEP file and

Include Paths (-I)

Other optimization flags:

-v0

and finally!

------ Build started: Project: coinForth, Configuration: Debug AVR ------

I had to change the project name from my_amforth to coinForth because amforth.asm opened my_amforth.asm, which makes the build fail.

I also had to turn off the EESAVE and BOOTRST fuses and change the BOOSTSZ fuse from 1024W_3C00 to 2048W_3800. (E.g. HIGH = 0xD9).

I found that amForth can not handle direct file input, but the 

C:\Users\Dennis\Documents\Atmel Studio\6.2\coinForth\amforth-5.8\tools>python amforth-shell.py

I haven't had a reason to use PowerShell yet, but this might be the time

Windows PowerShell
Copyright (C) 2014 Microsoft Corporation. All rights reserved.

PS C:\Users\Dennis> cd "C:\Users\Dennis\Documents\Atmel Studio\6.2\coinForth\amforth-5.8\tools"
PS C:\Users\Dennis\Documents\Atmel Studio\6.2\coinForth\amforth-5.8\tools> python .\amforth-shell.py
|I=appl_defs: 0 loaded
|I=Entering amforth interactive interpreter
|I=getting MCU name..
|I=successfully loaded register definitions for atmega328p
|I=getting filenames on the host
|I=  Reading C:\Users\Dennis\Documents\Atmel Studio\6.2\coinForth\amforth-5.8\avr8\devices\atmega328p
|I=  Reading C:\Users\Dennis\Documents\Atmel Studio\6.2\coinForth\amforth-5.8\avr8\lib
|I=  Reading .
|I=getting filenames from the controller
(ATmega328P)>
(ATmega328P)>
(ATmega328P)> ver
amforth 5.8 ATmega328P ok
(ATmega328P)>
