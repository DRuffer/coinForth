; ----------------------------------------------------------------------
; CamelForth for the Texas Instruments MSP430 
; (c) 2009,2014 Bradford J. Rodriguez.
; modified for the MSP430G2553, 26 Oct 2012
; 
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
; Commercial inquiries should be directed to the author at 
; 115 First St., #105, Collingwood, Ontario L9Y 4W3 Canada
; or via email to bj@camelforth.com
; ----------------------------------------------------------------------
; 430g2553init.asm: CPU Configuration - MSP430G2553
; B. Rodriguez  26 Oct 2012, modified for amforth
; 
; Clocks:
; on-chip oscillator is used
;
; ----------------------------------------------------------------------
; POWER ON RESET AND INITIALIZATION

; ----------------------------------------------------------------------
; MSP430F1611 INITIALIZATION
; The reset default is for all I/O pins configured as inputs,
; watchdog enabled, SR reset.

main:   ; Debugger requires the 'main' symbol.
reset:
        ; Watchdog Timer
        MOV   #(WDTPW+WDTHOLD),&WDTCTL    ; stop watchdog timer

        ; Basic Clock Module
        ; My thanks to the 4e4th team for the following two lines!
        MOV.B   &CALBC1_8MHZ, &BCSCTL1   ; Set DCO
        MOV.B   &CALDCO_8MHZ, &DCOCTL    ; to 8 MHz.
        
        MOV.B   #00h,&BCSCTL2           ; MCLK=DCO/1, SMCLK=DCO/1

        ; Flash Memory Controller
        ; Flash Timing Generator frequency must be 257-476 kHz.
        ; 8 MHZ/17 = 470.59 kHz.   tFTG=2.125 msec.
        ; At 470 kHz, byte/word program time is 35*tFTG = 75 usec.
        ; Cumulative program time to any 64-byte block (between erasures)
        ; must not exceed 4 msec, thus 53 writes at 250 kHz.  Therefore,
        ; do not use exclusively byte writes in a 64-byte block.
        ; Also, "a flash word (low + high byte) must not
        ; be written more than twice between erasures."
        ; Program/Erase endurance is 10,000 cycles minimum.
        MOV #FWKEY+0,&FCTL1             ; write & erase modes OFF
        MOV #FWKEY+FSSEL1+16,&FCTL2     ; SMCLK/17 = 471 kHz.
        MOV #FWKEY+LOCK,&FCTL3          ; lock flash memory against writing

        ; Interrupt Enables
        MOV.B   #0,&IE1                 ; no interrupts enabled
        MOV.B   #0,&IE2                 ; no interrupts enabled

        ; Forth registers
        MOV     #RSTACK,SP              ; set up stack
        MOV     #PSTACK,PSP
        MOV     #UAREA,&UP              ; initial user pointer
        
	; now hand over to Forth with COLD (a colon word)
        MOV     #XT_COLD+2,IP
        NEXT

; ----------------------------------------------------------------------
; DEFAULT INTERRUPT HANDLER

nullirq: RETI
